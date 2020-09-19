import requests
from io import BytesIO

import torch

# import torch.nn as nn
# import numpy as np
import os
import sys
from args import get_parser
import pickle
from model import get_model
from torchvision import transforms
from utils.output_utils import prepare_output
from PIL import Image
import traceback
import string
import random
import time
import json

import firebase_admin
from firebase_admin import credentials

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(os.path.join(os.path.dirname(__file__), "../.."))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../.."))

base_dir = "/home/david/Downloads/foxglove/"

cred = credentials.Certificate(os.path.join(base_dir, "carbon-foodprint-5881e-firebase-adminsdk-r0nck-3a0b85478e.json"))
firebase_admin.initialize_app(cred)

IG_USERNAME = "kolja.es"

tmp_json = os.path.join(base_dir, "tmp_store.json")
ig_tsmps = os.path.join(base_dir, "tmp.txt")
req_store = {}


class FoodProcessor:
    def __init__(
        self,
    ):

        transf_list = []
        transf_list.append(transforms.Resize(256))
        transf_list.append(transforms.CenterCrop(224))
        self.transform = transforms.Compose(transf_list)

        transf_list_batch = []
        transf_list_batch.append(transforms.ToTensor())
        transf_list_batch.append(transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225)))
        self.to_input_transf = transforms.Compose(transf_list_batch)

        data_dir = "data"
        # code will run in gpu if available and if the flag is set to True, else it will run on cpu
        use_gpu = False
        self.device = torch.device("cuda" if torch.cuda.is_available() and use_gpu else "cpu")
        map_loc = None if torch.cuda.is_available() and use_gpu else "cpu"

        self.ingrs_vocab = pickle.load(open(os.path.join(data_dir, "ingr_vocab.pkl"), "rb"))
        self.vocab = pickle.load(open(os.path.join(data_dir, "instr_vocab.pkl"), "rb"))

        ingr_vocab_size = len(self.ingrs_vocab)
        instrs_vocab_size = len(self.vocab)
        # output_dim = instrs_vocab_size

        args = get_parser()
        args.maxseqlen = 15
        args.ingrs_only = False
        model = get_model(args, ingr_vocab_size, instrs_vocab_size)
        # Load the trained model parameters
        model_path = os.path.join(data_dir, "modelbest.ckpt")
        model.load_state_dict(torch.load(model_path, map_location=map_loc))
        model.to(self.device)
        model.eval()
        model.ingrs_only = False
        model.recipe_only = False
        self.model = model
        print("loaded model")

        self.ingr_co2 = pickle.load(open(os.path.join(data_dir, "ingr_co2.pkl"), "rb"))
        self.ingr_alternatives = pickle.load(open(os.path.join(data_dir, "ingr_alt.pkl"), "rb"))


def get_random_string(length):
    # Random string with the combination of lower and upper case
    letters = string.ascii_letters
    result_str = "".join(random.choice(letters) for i in range(length))
    return result_str


def get_new_igpost(username=IG_USERNAME):
    from scraper import InstagramScraper

    scaper = InstagramScraper(username=username, latest_stamps=ig_tsmps)
    items = scaper.scrape()

    scaper.set_last_scraped_timestamp(username, 100)

    urls = [i["display_url"] for i in items]

    return urls


def process_url(url, food_processor):
    try:

        response = requests.get(url, stream=True)
        image = Image.open(BytesIO(response.content))

        print("Got Image")

        image_transf = food_processor.transform(image)
        image_tensor = food_processor.to_input_transf(image_transf).unsqueeze(0).to(food_processor.device)

        print("Image Transformed")

        with torch.no_grad():
            outputs = food_processor.model.sample(image_tensor, greedy=True, temperature=1.0, beam=-1, true_ingrs=None)

        print("Got outputs")

        ingr_ids = outputs["ingr_ids"].cpu().numpy()
        recipe_ids = outputs["recipe_ids"].cpu().numpy()

        outs, valid = prepare_output(recipe_ids[0], ingr_ids[0], food_processor.ingrs_vocab, food_processor.vocab)

        is_valid = valid["is_valid"]
        title = outs["title"]

        recipes = outs["recipe"]

        ingrids = []
        new_ingrids = []
        alt_ingrids = {}

        for ingr in outs["ingrs"]:
            ingrids.append((ingr, food_processor.ingr_co2[ingr]))
            if len(food_processor.ingr_alternatives[ingr]) > 0:
                alt_ingrids[ingr] = food_processor.ingr_alternatives[ingr]

                # print(ingr, ingr_alternatives[ingr])

                new_ingr = food_processor.ingr_alternatives[ingr][0][0]
                new_ingrids.append((new_ingr, food_processor.ingr_co2[new_ingr]))

                for i, step_ in enumerate(recipes):
                    step_ = step_.replace(ingr, new_ingr)
                    recipes[i] = step_
            else:
                new_ingrids.append((ingr, food_processor.ingr_co2[ingr]))

        # ingrids = outs["ingrs"]

    except Exception:
        is_valid = False
        title = "Awesome Recipe"
        ingrids = [("Potatoes", 1.0), ("And more Potatoes", 1.0)]
        alt_ingrids = {"Potatoes": [("Carrott", 0.5)]}
        new_ingrids = [("Carrot", 0.5), ("And more Potatoes", 1.0)]
        recipes = ["Eat", "Sleep", "Train", "Repeat"]
        traceback.print_stack()

    ret_dict = {
        "title": title,
        "ingredients": ingrids,
        "new": new_ingrids,
        "alternatives": alt_ingrids,
        "instructions": recipes,
        "is_valid": is_valid,
        "url": url,
    }

    id_ = get_random_string(16)
    req_store[id_] = ret_dict

    with open(tmp_json, "w") as fp_:
        json.dump(req_store, fp_)

    return {"id": id_}


def send_to_topic(payload):
    # [START send_to_topic]
    # The topic name can be optionally prefixed with "/topics/".
    from firebase_admin import messaging

    topic = "foods"

    # See documentation on defining a message payload.
    payload["click_action"] = "FLUTTER_NOTIFICATION_CLICK"

    message = messaging.Message(
        data=payload,
        topic=topic,
    )

    # Send a message to the devices subscribed to the provided topic.
    response = messaging.send(message)
    # Response is a message ID string.
    print("Successfully sent message:", response)
    # [END send_to_topic]


def do_the_magic_loop():

    food_processor = FoodProcessor()

    while True:

        urls = get_new_igpost()

        for url in urls:
            print("Found a URL:", url)
            id_dict = process_url(url, food_processor)
            send_to_topic(payload=id_dict)

        print("Sleeping now")
        time.sleep(600)


if __name__ == "__main__":
    do_the_magic_loop()
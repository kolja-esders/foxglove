from flask import Flask, request, jsonify
import requests
from io import BytesIO

import torch

# import torch.nn as nn
# import numpy as np
import os
from args import get_parser
import pickle
from model import get_model
from torchvision import transforms
from utils.output_utils import prepare_output
from PIL import Image
import traceback
import urllib

app = Flask(__name__)

transf_list = []
transf_list.append(transforms.Resize(256))
transf_list.append(transforms.CenterCrop(224))
transform = transforms.Compose(transf_list)

transf_list_batch = []
transf_list_batch.append(transforms.ToTensor())
transf_list_batch.append(transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225)))
to_input_transf = transforms.Compose(transf_list_batch)

data_dir = "data"
# code will run in gpu if available and if the flag is set to True, else it will run on cpu
use_gpu = False
device = torch.device("cuda" if torch.cuda.is_available() and use_gpu else "cpu")
map_loc = None if torch.cuda.is_available() and use_gpu else "cpu"

ingrs_vocab = pickle.load(open(os.path.join(data_dir, "ingr_vocab.pkl"), "rb"))
vocab = pickle.load(open(os.path.join(data_dir, "instr_vocab.pkl"), "rb"))

ingr_vocab_size = len(ingrs_vocab)
instrs_vocab_size = len(vocab)
output_dim = instrs_vocab_size

args = get_parser()
args.maxseqlen = 15
args.ingrs_only = False
model = get_model(args, ingr_vocab_size, instrs_vocab_size)
# Load the trained model parameters
model_path = os.path.join(data_dir, "modelbest.ckpt")
model.load_state_dict(torch.load(model_path, map_location=map_loc))
model.to(device)
model.eval()
model.ingrs_only = False
model.recipe_only = False
print("loaded model")

ingr_co2 = pickle.load(open(os.path.join(data_dir, "ingr_co2.pkl"), "rb"))
ingr_alternatives = pickle.load(open(os.path.join(data_dir, "ingr_alt.pkl"), "rb"))

# @app.route("/")
# def index():
#     return "Hello, World!"


@app.route("/food", methods=["GET"])
def index():
    url = request.args.get("url")
    url = urllib.parse.unquote(url)

    print("Got URL")

    if True:
        # try:

        response = requests.get(url, stream=True)
        image = Image.open(BytesIO(response.content))

        print("Got Image")

        image_transf = transform(image)
        image_tensor = to_input_transf(image_transf).unsqueeze(0).to(device)

        print("Image Transformed")

        with torch.no_grad():
            outputs = model.sample(image_tensor, greedy=True, temperature=1.0, beam=-1, true_ingrs=None)

        print("Got outputs")

        ingr_ids = outputs["ingr_ids"].cpu().numpy()
        recipe_ids = outputs["recipe_ids"].cpu().numpy()

        outs, valid = prepare_output(recipe_ids[0], ingr_ids[0], ingrs_vocab, vocab)

        is_valid = valid["is_valid"]
        title = outs["title"]

        recipes = outs["recipe"]

        ingrids = []
        new_ingrids = []
        alt_ingrids = {}

        for ingr in outs["ingrs"]:
            ingrids.append((ingr, ingr_co2[ingr]))
            if len(ingr_alternatives[ingr]) > 0:
                alt_ingrids[ingr] = ingr_alternatives[ingr]

                print(ingr, ingr_alternatives[ingr])

                new_ingr = ingr_alternatives[ingr][0][0]
                new_ingrids.append((new_ingr, ingr_co2[new_ingr]))

                for i, step_ in enumerate(recipes):
                    step_ = step_.replace(ingr, new_ingr)
                    recipes[i] = step_
            else:
                new_ingrids.append((ingr, ingr_co2[ingr]))

        # ingrids = outs["ingrs"]

    # except Exception:
    #     is_valid = False
    #     title = "Awesome Recipe"
    #     ingrids = [("Potatoes", 1.0), ("And more Potatoes", 1.0)]
    #     alt_ingrids = {"Potatoes": [("Carrott", 0.5)]}
    #     new_ingrids = [("Carrot", 0.5), ("And more Potatoes", 1.0)]
    #     recipes = ["Eat", "Sleep", "Train", "Repeat"]
    #     traceback.print_stack()

    ret_dict = {
        "title": title,
        "ingredients": ingrids,
        "new": new_ingrids,
        "alternatives": alt_ingrids,
        "instructions": recipes,
        "is_valid": is_valid,
        "url": url,
    }

    # if valid["is_valid"] or show_anyways:

    #     print("RECIPE")
    #     # print ("greedy:", greedy[i], "beam:", beam[i])

    #     BOLD = "\033[1m"
    #     END = "\033[0m"
    #     print(BOLD + "\nTitle:" + END, outs["title"])

    #     print(BOLD + "\nIngredients:" + END)
    #     print(", ".join(outs["ingrs"]))

    #     print(BOLD + "\nInstructions:" + END)
    #     print("-" + "\n-".join(outs["recipe"]))

    #     print("=" * 20)

    return jsonify(ret_dict)


if __name__ == "__main__":
    app.run(debug=False)
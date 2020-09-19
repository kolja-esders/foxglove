import pickle
import os
import numpy as np
import random
from collections import defaultdict


def parse_co2():

    co2_dict = {}

    import urllib.request

    fp = urllib.request.urlopen("https://healabel.com/carbon-footprint-of-foods")
    mybytes = fp.read()

    mystr = mybytes.decode("utf8")
    fp.close()

    # print(mystr)

    str_splits = mystr.split('<p class="" style="white-space:pre-wrap;">')

    for str_spl in str_splits[1:]:
        if str_spl.startswith("<a"):
            food_name = str_spl.split('">')[1].split("</a>")[0]
        else:
            food_name = str_spl.split(",")[0]

        if "(" in food_name:
            food_name = food_name.split("(")[0]

        kg_co2 = str_spl.split("<strong>")[1].split("</strong>")[0]
        kg_co2 = kg_co2.replace("kg", "")
        kg_co2 = kg_co2.replace("CO2e", "")

        if "-" in kg_co2:
            kg_co2 = kg_co2.split("-")[0]

        print(food_name, float(kg_co2))

        co2_dict[food_name.lower().strip().replace(" ", "_")] = float(kg_co2)

    return co2_dict


def build_ingridient_maps():

    co2_dict = parse_co2()

    data_dir = "data"

    ingrs_vocab = pickle.load(open(os.path.join(data_dir, "ingr_vocab.pkl"), "rb"))

    ingr_co2_map = {}

    for ingr in ingrs_vocab:
        if "<" not in ingr:
            # ingr_co2_map[ingr] = np.max(0.0, (np.random.randn() + 2.0) * 2.0)
            ingr_co2_map[ingr] = np.max(((np.random.randn() + 1.0) * 2, 0.01))

            if (
                "beef" in ingr
                or "pork" in ingr
                or "meat" in ingr
                or "pig" in ingr
                or "duck" in ingr
                or "chick" in ingr
                or "lamb" in ingr
                or "cow" in ingr
                or "wurst" in ingr
                or "bird" in ingr
                or "deer" in ingr
            ):
                ingr_co2_map[ingr] = ingr_co2_map[ingr] * np.random.randint(3, 10)

            for parsed_food in co2_dict:
                if parsed_food in ingr:
                    ingr_co2_map[ingr] = co2_dict[parsed_food]
                    print(f"Found match: {parsed_food} - {ingr}")

            print(ingr, ingr_co2_map[ingr])

    with open(os.path.join(data_dir, "ingr_co2.pkl"), "wb") as pf_:
        pickle.dump(ingr_co2_map, pf_)

    low_foods = {ingr: val for ingr, val in ingr_co2_map.items() if val < 1.5}

    ingr_alternatives = defaultdict(list)

    for ingr in ingrs_vocab:
        if "<" not in ingr and ingr_co2_map[ingr] > 3.0:
            for i in range(np.random.randint(1, 4)):
                alt_ingr = random.choice(list(low_foods.keys()))
                ingr_alternatives[ingr].append((alt_ingr, ingr_co2_map[alt_ingr]))

        # print(ingr, ingr_alternatives[ingr])

    with open(os.path.join(data_dir, "ingr_alt.pkl"), "wb") as pf_:
        pickle.dump(ingr_alternatives, pf_)


if __name__ == "__main__":
    build_ingridient_maps()
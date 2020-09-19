import pickle
import os
import numpy as np
import random
from collections import defaultdict


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
            ingr_co2_map[ingr] * np.random.randint(3, 10)

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

    print(ingr, ingr_alternatives[ingr])

with open(os.path.join(data_dir, "ingr_alt.pkl"), "wb") as pf_:
    pickle.dump(ingr_alternatives, pf_)
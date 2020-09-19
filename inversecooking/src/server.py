import os
import sys
import urllib
import json
import traceback

from flask import Flask, request, jsonify

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(os.path.join(os.path.dirname(__file__), "../.."))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../.."))


app = Flask(__name__)

req_store = {}
base_dir = "/home/david/Downloads/foxglove/"
tmp_json = os.path.join(base_dir, "tmp_store.json")


# @app.route("/")
# def index():
#     return "Hello, World!"


@app.route("/food", methods=["GET"])
def process_img():
    from worker import process_url, FoodProcessor

    food_processor = FoodProcessor()

    url = request.args.get("url")
    url = urllib.parse.unquote(url)

    print("Got URL")

    return jsonify(process_url(url, food_processor))


@app.route("/id", methods=["GET"])
def get_content():

    id_ = request.args.get("id")

    try:

        with open(tmp_json, "r") as fp_:
            req_store = json.load(fp_)

        if id_ not in req_store:
            raise KeyError("ID not found")

        ret_dict = req_store[id_]

    except KeyError:
        print("Key not found")
        is_valid = False
        title = "Awesome Recipe"
        ingrids = [("Potatoes", 1.0), ("And more Potatoes", 1.0)]
        alt_ingrids = {
            "Potatoes": [("Carrott", 0.5), ("Pumpkin", 0.4)],
            "And more Potatoes": [("Pumpkin", 0.4), ("Carrot", 0.5)],
        }
        new_ingrids = [("Carrot", 0.5), ("Pumpkin", 0.4)]
        recipes = ["Eat", "Sleep", "Train", "Repeat"]

        ret_dict = {
            "title": title,
            "ingredients": ingrids,
            "new": new_ingrids,
            "alternatives": alt_ingrids,
            "instructions": recipes,
            "is_valid": is_valid,
            "url": "https://www.196flavors.com/wp-content/uploads/2014/10/california-roll-3-FP.jpg",
        }

    except Exception:
        is_valid = False
        title = "Awesome Recipe"
        ingrids = [("Potatoes", 1.0), ("And more Potatoes", 1.0)]
        alt_ingrids = {"Potatoes": [("Carrott", 0.5)]}
        new_ingrids = [("Carrot", 0.5), ("And more Potatoes", 1.0)]
        recipes = ["Eat", "Sleep", "Train", "Repeat"]
        traceback.print_exc()

        ret_dict = {
            "title": title,
            "ingredients": ingrids,
            "new": new_ingrids,
            "alternatives": alt_ingrids,
            "instructions": recipes,
            "is_valid": is_valid,
            "url": "https://www.196flavors.com/wp-content/uploads/2014/10/california-roll-3-FP.jpg",
        }

    return jsonify(ret_dict)


if __name__ == "__main__":
    app.run(debug=False)
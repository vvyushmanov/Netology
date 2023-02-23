import json


with open('bad.json', 'r') as imported:
    js_dict = json.load(imported)
    print(js_dict)





import yaml

with open('services.yml', 'r') as imported:
    dict = yaml.safe_load(imported)
    print(type(dict))
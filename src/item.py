import csv


def load_csv_offers(path, item_list):
    "Updates input item list by adding offers from csv file"
    with open(path, newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=",")
        for row in reader:
            name = row[0]
            offers = [x for x in row[1:] if x != ""]
            is_modified = False
            for item in item_list:
                if item.name == name:
                    is_modified = True
                    item.offers = offers
                    break
            if not is_modified:
                item_list.append(Item(name).with_offers(offers))


def load_csv_needs(path, item_list):
    "Updates input item list by adding needs from csv file"
    with open(path, newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=",")
        for row in reader:
            name = row[0]
            needs = [x for x in row[1:] if x != ""]
            is_modified = False
            for item in item_list:
                if item.name == name:
                    is_modified = True
                    item.needs = needs
                    break
            if not is_modified:
                item_list.append(Item(name).with_needs(needs))


class Item:
    def __init__(self, name):
        self.name = name
        self.tags = []
        self.needs = []
        self.offers = []

    def __repr__(self):
        return self.name

    def __eq__(self, other):
        return self.name == other.name
    
    def with_tags(self, tag_list):
        self.tags = tag_list
        return self
    
    def with_needs(self, need_list):
        self.needs = need_list
        return self

    def with_offers(self, offer_list):
        self.offers = offer_list
        return self

    

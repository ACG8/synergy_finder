import csv


def load_item_list(path):
    item_list = []
    with open(path, newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=",")
        for row in reader:
            name = row[0]
            attributes = [x for x in row[1:] if x != ""]
            offers = [a[1:] for a in attributes if a.startswith("+")]
            needs = [a[1:] for a in attributes if a.startswith("-")]
            tags = [a for a in attributes if (not a.startswith("+")) and (not a.startswith("-"))]
            item_list.append(Item(name)\
                             .with_offers(offers)\
                             .with_needs(needs)\
                             .with_tags(tags))
    return item_list

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

    

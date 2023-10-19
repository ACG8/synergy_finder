def rank(all_items, current_items):
    candidate_items = all_items
    for item in current_items:
        candidate_items.remove(item)
    sort_criterion = lambda item: -score([item] + current_items)    # Highest scores first
    candidate_items = sorted(candidate_items, key=sort_criterion)
    return candidate_items


def score(item_list):
    "Scores a list of items. Each need/offer scores according to its product"
    offers = count_offers(item_list)
    needs = count_needs(item_list)
    score = 0
    for key, count in offers.items():
        score += count * needs.get(key, 0)
    return score


def count_offers(item_list):
    "Returns dictionary counting each offer from the items in input list"
    offers = {}
    for item in item_list:
        for offer in item.offers:
            offers[offer] = offers.setdefault(offer,0) + 1
    return offers


def count_needs(item_list):
    "Returns dictionary counting each need from the items in input list"
    needs = {}
    for item in item_list:
        for need in item.needs:
            needs[need] = needs.setdefault(need,0) + 1
    return needs

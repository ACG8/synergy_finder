def rank_unselected(unselected_items, selected_items):
    "sorts unselected items in place ascending according to their scores against the selected items"
    sort_criterion = lambda item: score_margin(item, selected_items)
    return sorted(unselected_items, key=sort_criterion)


def rank_selected(selected_items):
    "sorts selected items in place ascending according to their scores against the other selected items"
    sort_criterion = lambda item: score_margin(item, [i for i in selected_items if i != item])
    return sorted(selected_items, key=sort_criterion)
    

def score_margin(item, selected_items):
    "Scores one item according to how much it modifies the synergies a list of already selected items"
    offers = count_offers(selected_items)
    needs = count_needs(selected_items)
    score = 0
    for key, count in offers.items():
        if key in item.needs:
            score += count
    for key, count in needs.items():
        if key in item.offers:
            score += count
    return score


def score_selection(selected_items):
    "Scores list of items according to synergy"
    offers = count_offers(selected_items)
    needs = count_needs(selected_items)
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

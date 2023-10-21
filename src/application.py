from item import load_item_list
import recommender

class Application:

    def __init__(self, data_path):
        self.hidden = []
        self.unselected = load_item_list(data_path)
        self.selected = []
        

    def sort_unselected(self):
        self.unselected = list(reversed(
            recommender.rank_unselected(self.unselected, self.selected)
        ))

    def sort_selected(self):
        "sort selected list in ascending order by marginal gains"
        self.selected = recommender.rank_selected(self.selected)

    def select(self, index):
        self.selected.append(self.unselected.pop(index))

    def unselect(self, index):
        self.unselected.append(self.selected.pop(index))

    def get_tags(self):
        all_items = self.hidden + self.unselected + self.selected
        tags = set()
        for item in all_items:
            tags |= set(item.tags)
        return tags

    def filter(self, tags):
        all_unselected_items = self.hidden + self.unselected
        self.hidden = []
        self.unselected = []
        if not tags:
            self.unselected = all_unselected_items
            return
        for item in all_unselected_items:
            if set(item.tags) & set(tags):
                self.unselected.append(item)
            else:
                self.hidden.append(item)
                

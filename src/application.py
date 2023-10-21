import item
import recommender

class Application:

    def __init__(self, data_path):
        self.unselected = item.load_item_list(data_path)
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

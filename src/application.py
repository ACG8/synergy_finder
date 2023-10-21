import item
import recommender

class Application:

    def __init__(self, needs_path=None, offers_path=None):
        self.unselected = []
        assert(needs_path is not None)
        assert(offers_path is not None)
        item.load_csv_offers(offers_path, self.unselected)
        item.load_csv_needs(needs_path, self.unselected)
        
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

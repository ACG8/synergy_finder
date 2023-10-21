import unittest
import sys
sys.path.insert(0, "../src")
import recommender
import application
from item import Item


class TestSorting(unittest.TestCase):

# Marginal values:
# Fire: +smoke (+1), -fuel(+1), -oxygen(+1)
# Water: +moisture (+1)
# Air: +oxygen (+2)
# Earth: -smoke(+1), +fuel(+1), -moisture(+1), -oxygen(+1)

    def test_sort_unselected(self):
        app = application.Application("test_data.csv")
        app.select(0)
        app.sort_unselected()
        self.assertEqual(app.unselected, [Item("earth"), Item("air"), Item("water")])

    def test_sort_selected(self):
        app = application.Application("test_data.csv")
        app.select(0)
        app.select(0)
        app.select(0)
        app.select(0)
        app.sort_selected()
        self.assertEqual(app.selected, [Item("water"), Item("air"), Item("fire"), Item("earth")])


if __name__ == "__main__":
    unittest.main()

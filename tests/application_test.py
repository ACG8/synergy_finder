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

class TestFilter(unittest.TestCase):

    def test_get_tags(self):
        app = application.Application("test_data.csv")
        tags = app.get_tags()
        self.assertEqual(len(tags), 3)
        self.assertEqual(tags, set(["reaction", "fluid", "solid"]))

    def test_no_filter(self):
        app = application.Application("test_data.csv")
        app.filter([])
        self.assertIn(Item("fire"), app.unselected)
        self.assertIn(Item("water"), app.unselected)
        self.assertIn(Item("air"), app.unselected)
        self.assertIn(Item("earth"), app.unselected)
        self.assertNotIn(Item("fire"), app.hidden)
        self.assertNotIn(Item("water"), app.hidden)
        self.assertNotIn(Item("air"), app.hidden)
        self.assertNotIn(Item("earth"), app.hidden)        

    def test_filter(self):
        app = application.Application("test_data.csv")
        app.filter(["fluid"])
        self.assertIn(Item("fire"), app.hidden)
        self.assertIn(Item("water"), app.unselected)
        self.assertIn(Item("air"), app.unselected)
        self.assertIn(Item("earth"), app.hidden)
        self.assertNotIn(Item("fire"), app.unselected)
        self.assertNotIn(Item("water"), app.hidden)
        self.assertNotIn(Item("air"), app.hidden)
        self.assertNotIn(Item("earth"), app.unselected)

    def test_multi_filter(self):
        app = application.Application("test_data.csv")
        app.filter(["fluid", "reaction"])
        self.assertIn(Item("fire"), app.unselected)
        self.assertIn(Item("water"), app.unselected)
        self.assertIn(Item("air"), app.unselected)
        self.assertIn(Item("earth"), app.hidden)
        self.assertNotIn(Item("fire"), app.hidden)
        self.assertNotIn(Item("water"), app.hidden)
        self.assertNotIn(Item("air"), app.hidden)
        self.assertNotIn(Item("earth"), app.unselected)

if __name__ == "__main__":
    unittest.main()

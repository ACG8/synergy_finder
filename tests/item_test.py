import unittest
import itertools
import sys
sys.path.insert(0, "../src")
import item


class TestItemClass(unittest.TestCase):

    def test_item_equality(self):
        item_a = item.Item("a")
        item_b = item.Item("a")
        item_c = item.Item("b")
        self.assertEqual(item_a, item_b)
        self.assertNotEqual(item_a, item_c)
        self.assertNotEqual(item_b, item_c)

class TestCsvImports(unittest.TestCase):

    def test_load_item_list_should_work(self):
        item_list = item.load_item_list("test_data.csv")
        self.assertIn(item.Item("fire"), item_list)
        self.assertIn(item.Item("water"), item_list)
        self.assertIn(item.Item("air"), item_list)
        self.assertIn(item.Item("earth"), item_list)
        for entry in item_list:
            if entry.name == "fire":
                self.assertEqual(entry.offers, ["heat", "smoke"])
                self.assertEqual(entry.needs, ["oxygen", "fuel"])
                self.assertEqual(entry.tags, ["reaction"])
            if entry.name == "water":
                self.assertEqual(entry.offers, ["moisture"])
                self.assertEqual(entry.needs, ["cool"])
                self.assertEqual(entry.tags, ["fluid"])
            if entry.name == "air":
                self.assertEqual(entry.offers, ["oxygen"])
                self.assertEqual(entry.needs, [])
                self.assertEqual(entry.tags, ["fluid"])
            if entry.name == "earth":
                self.assertEqual(entry.offers, ["fuel"])
                self.assertEqual(entry.needs, ["smoke", "moisture", "oxygen"])
                self.assertEqual(entry.tags, ["solid"])

if __name__ == "__main__":
    unittest.main()

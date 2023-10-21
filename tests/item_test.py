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
    
    def test_load_csv_offers_should_work(self):
        item_list = []
        item.load_csv_offers("test_csv_offers.csv", item_list)
        fire = item.Item("fire")
        water = item.Item("water")
        self.assertIn(fire, item_list)
        self.assertIn(water, item_list)
        for thing in item_list:
            if thing == fire:
                self.assertEqual(thing.offers, ["heat", "smoke"])
            if thing == water:
                self.assertEqual(thing.offers, ["moisture"])

    def test_load_csv_needs_should_work(self):
        item_list = []
        item.load_csv_needs("test_csv_needs.csv", item_list)
        fire = item.Item("fire")
        water = item.Item("water")
        self.assertIn(fire, item_list)
        self.assertIn(water, item_list)
        for thing in item_list:
            if thing == fire:
                self.assertEqual(thing.needs, ["oxygen", "fuel"])
            if thing == water:
                self.assertEqual(thing.needs, ["cool"])

    def test_load_csv_needs_and_offers_should_work(self):
        item_list = []
        item.load_csv_needs("test_csv_needs.csv", item_list)
        item.load_csv_offers("test_csv_offers.csv", item_list)        
        self.assertEqual(len(item_list), 2)
        fire = item.Item("fire")
        water = item.Item("water")
        self.assertIn(fire, item_list)
        self.assertIn(water, item_list)
        for thing in item_list:
            if thing == fire:
                self.assertEqual(thing.offers, ["heat", "smoke"])
                self.assertEqual(thing.needs, ["oxygen", "fuel"])
            if thing == water:
                self.assertEqual(thing.offers, ["moisture"])
                self.assertEqual(thing.needs, ["cool"])

if __name__ == "__main__":
    unittest.main()

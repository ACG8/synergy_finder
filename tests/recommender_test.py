import unittest
import itertools
import sys
sys.path.insert(0, "../src")
import recommender
from item import Item


class TestRank(unittest.TestCase):

    def test_rank_output_should_ignore_current_items(self):
        item_a = Item("a")
        item_b = Item("b")
        ranked_items = recommender.rank([item_a, item_b],[item_b])
        self.assertIn(item_a, ranked_items)
        self.assertNotIn(item_b, ranked_items)

    def test_rank_prioritizes_items_with_more_matches(self):
        item_a = Item("a").with_needs(["a"])
        item_b = Item("b").with_offers(["a"])
        item_c = Item("c")
        for perm in itertools.permutations([item_a, item_b, item_c]):
            ranked_items = recommender.rank(list(perm),[item_b])
            self.assertEqual(ranked_items, [item_a, item_c])

class TestScore(unittest.TestCase):

    def test_score_should_give_product(self):
        item_a = Item("a").with_needs(["a","b"])
        item_b = Item("b").with_offers(["a"])
        item_c = Item("c").with_offers(["a","b","c"])
        score = recommender.score([item_a, item_b, item_c])
        self.assertEqual(score, 3)

class TestCounters(unittest.TestCase):

    def test_count_offers_should_work(self):
        item_a = Item("a").with_offers(["a"])
        item_b = Item("b").with_offers(["a"])
        item_c = Item("c").with_offers(["b"])
        offers = recommender.count_offers([item_a, item_b, item_c])
        self.assertEqual(offers, {"a":2, "b":1})

    def test_count_needs_should_work(self):
        item_a = Item("a").with_needs(["a"])
        item_b = Item("b").with_needs(["a"])
        item_c = Item("c").with_needs(["b"])
        needs = recommender.count_needs([item_a, item_b, item_c])
        self.assertEqual(needs, {"a":2, "b":1})


if __name__ == "__main__":
    unittest.main()

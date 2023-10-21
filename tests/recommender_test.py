import unittest
import itertools
import sys
sys.path.insert(0, "../src")
import recommender
from item import Item


class TestRank(unittest.TestCase):

    def test_rank_unselected_prioritizes_items_with_more_matches(self):
        item_a = Item("a").with_needs(["a", "b"])
        item_b = Item("b").with_offers(["a", "b"])
        item_c = Item("c").with_offers(["a"])
        item_d = Item("d")
        ranked_items = recommender.rank_unselected([item_b, item_c, item_d],[item_a])
        for perm in itertools.permutations([item_b, item_c, item_d]):
            ranked_items = recommender.rank_unselected(list(perm),[item_a])
            self.assertEqual(ranked_items, [item_d, item_c, item_b])

    def test_rank_selected_prioritizes_items_with_more_matches(self):
        item_a = Item("a").with_needs(["a", "b"])
        item_b = Item("b").with_offers(["a", "b"])
        item_c = Item("c").with_offers(["a"])
        item_d = Item("d")
        for perm in itertools.permutations([item_a, item_b, item_c, item_d]):
            ranked_items = recommender.rank_selected(list(perm))
            self.assertEqual(ranked_items, [item_d, item_c, item_b, item_a])

class TestScore(unittest.TestCase):

    def test_score_margin_should_give_marginal_gains(self):
        item_a = Item("a").with_needs(["a","b","c"])
        item_b = Item("b").with_offers(["a"])
        item_c = Item("c").with_offers(["a","b"])
        item_d = Item("d").with_offers(["a","b","c"])
        self.assertEqual(recommender.score_margin(item_a,[item_b, item_c, item_d]), 6)
        self.assertEqual(recommender.score_margin(item_b,[item_a, item_c, item_d]), 1)
        self.assertEqual(recommender.score_margin(item_c,[item_a, item_b, item_d]), 2)
        self.assertEqual(recommender.score_margin(item_d,[item_a, item_b, item_c]), 3)

    def test_score_selection_should_give_total_score(self):
        item_a = Item("a").with_needs(["a","b","c"])
        item_b = Item("b").with_offers(["a"])
        item_c = Item("c").with_offers(["a","b"])
        item_d = Item("d").with_offers(["a","b","c"])
        self.assertEqual(recommender.score_selection([item_a, item_b, item_c, item_d]), 6)


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

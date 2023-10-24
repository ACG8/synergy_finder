class Item {
	constructor(name) {
		this.name = name;
	}

	with_tags(tag_list) {
		this.tags = tags;
		return this
	}

	with_needs(need_list) {
		this.needs = need_list;
		return this
	}

	with_offers(offer_list) {
		this.offers = offer_list;
		return this
	}

	static load_from_csv(path) {
		return [1,2,3,4];
	}
}

module.exports = {
	Item:Item
}
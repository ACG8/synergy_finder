const Item = require('../src/items').Item;
const expect = require('chai').expect;

describe('Testing item list loading', function() {
	it('Should load fire correctly', function(done) {
		let item_list = Item.load_from_csv("test_data.csv");
		expect(item_list[0].name).to.equal("fire");
		expect(item_list[0].tags).to.equal(["reaction"]);
		expect(item_list[0].needs).to.equal(["oxygen", "fuel"]);
		expect(item_list[0].offers).to.equal(["heat", "smoke"]);
		done();
	});
	it('Should load water correctly', function(done) {
		let item_list = Item.load_from_csv("test_data.csv");
		expect(item_list[0].name).to.equal("water");
		expect(item_list[0].tags).to.equal(["fluid"]);
		expect(item_list[0].needs).to.equal(["cool"]);
		expect(item_list[0].offers).to.equal(["moisture"]);
		done();
	});
});
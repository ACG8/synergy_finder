# Synergy Finder

This web app is intended to help find synergies between different items when building a list of items.

## Use Cases
In many tabletop and video games, players build a list of game components that synergize. Synergy Finder helps uncover links between different items when making such lists.

### Examples
* TCGs like Pokemon, Yugioh, and Magic require players to build decks of cards before playing
* Script-based games like Blood on the Clocktower require the gamemaster to choose roles to include
* Many TTRPGs involve building characters by choosing from lists of traits and abilities
* Team-based games like Spirit Island often have characters that work well or poorly together

## How to Use
You can access the web app at https://acg8.github.io/synergy_finder/
To use the app, you must provide data as a CSV file. Examples can be found in the example directory.

The app comprises two lists: a list of unselected items and a list of selected items. Each item is given a "synergy" score, which ranks how well it synergizes with the other selected items. Both lists are sorted in descending order of synergy.
You can mouse over any item to see a breakdown of which factors contribute to its synergy score.

## How to Define the data file
The data that you upload to the up must be in the form of a CSV (comma-separated value) file. The leftmost entry in each row must be the name or identifier for the item that row represents. All other entries, in any order, are either **tags**, **needs**, or **offers**. Empty strings are ignored, which can be convenient when formatting the CSV using a spreadsheet program.
* Tags have no prefix and are used purely for filtering data in the app
* Needs are prefixed by a "-" and represent characteristics which benefit that item
* Offers are prefixed by a "+" and represent characteristics of that item which benefit certain other items

The synergy score of any given item is equal to the number of needs met by its offers and the number of offers that satisfy its needs (among the other items in the "selected" list)

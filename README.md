# PokéCalc

This source code is accessible at [this Github repository link](https://github.com/TianLangHin/PokeCalc).

**Team Members:**

* Tian Lang Hin (24766127), GitHub username `TianLangHin`
* Duong Anh Tran (24775456), GitHub username `DuongAnhTran`
* Isabella Watt (24843322), GitHub username `Payayaing`

## Application Description

PokéCalc is a team-on-team Pokémon damage calculation application for the iOS platform that also serves as a team planner.
The user can manually build their teams, or import them from PokéPaste text format via a Share extension.
This application also has a custom Widget that shows the user one of their favourited teams from the home screen.

PokéCalc is developed using Swift, 
utilising frameworks such as SwiftUI and WidgetKit to construct the user interface,
and SQLite3 for local information storage.
In addition, all Pokémon related information, such as species details, moves, and held items,
is collected through PokéAPI, which can be accessed using the following links:

* [Official Documentation](https://pokeapi.co/docs/v2)
* [Official GitHub](https://github.com/PokeAPI/pokeapi)

It is important to note that the application requires an internet connection
to work as most data is fetched directly from the API.
Without an internet connection, the user is unable to:

* Use the calculator functionality, and
* Add new Pokémon or search through existing sets. However, the user is able to edit existing Pokémon.

## Minimum Deployment

Although designed to support the iOS platform, iPadOS devices can also be used.
However, this will not provide the best experience of the application.
The minimum deployment is iOS 18.1, and as such, versions of iOS below this benchmark will not be able to run this application.

## Features and Functionalities

PokéCalc supports:
* Calculating damage of a selected move to a Pokémon in an opposing team.
The user can swipe on Pokémon icons to select different members of both teams.
* Creating teams by either manually inputting Pokémon details,
or by using the Share extension that automatically creates a team containing the imported Pokémon.
* Viewing favourited teams on the iOS home screen using the Widget.
* Viewing all sets of a specific species of Pokémon across all stored teams.
* Stores all Pokémon teams using SQLite3.

## User Instructions

The first time the application is opened on a device, the user is shown an in-app demonstration,
guiding the user through its functionalities.
This includes creating a team, adding Pokémon to a team, editing the Pokémon, and calculating damage between two selected Pokémon. 

The user can navigate between four main screens using the persistent tab at the bottom of the screen.
* The **Pokémon** page allows the user to search for all stored Pokémon across all teams.
* The **Teams** page contains a list of all stored teams, which the user can individually select and edit.
* The **Calculator** page allows the user to select two of their stored teams and select a valid move
to calculate the damage that would be done to the opposing Pokémon.
The user can swap between the attacking and defending team,
and swipe on the Pokémon icon to go through the entire selected team’s Pokémon.
* The **Guide** page re-shows the guide that the user was presented upon the first time opening the application,
allowing them to look back on it at any time if they are unsure how to operate the application.

It is highly recommended that the user store at least one team prior to using the calculator,
as it is the minimum requirement for the calculator to function as intended.


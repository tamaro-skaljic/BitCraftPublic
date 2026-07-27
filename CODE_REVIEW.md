# Code Review

## Static Data

Every static data table is defined in [game/src/messages/static_data.rs](BitCraftServer/packages/game/src/messages/static_data.rs).

Every one of these tables uses an attribute proc macro defined in [bitcraft-macro/src/lib.rs](BitCraftServer/packages/game/bitcraft-macro/src/lib.rs#L13-L36) to add another `staged_` table with the same structure.

The build script [game/build_shared.rs#L376-L553](BitCraftServer/packages/game/build_shared.rs#L376-L553) finds every one of these static data tables and generates the file [game/src/game/autogen/_static_data.rs](BitCraftServer/packages/game/src/game/autogen/_static_data.rs) which contains an admin-only reducer for each one of these static data tables to add data to them without validation.

There is also one reducer generated to clear every one of these tables and another one is generated to validate that none of the tables have 0 rows in them.

There is also the over 4000 lines long [game/src/import_reducers.rs](BitCraftServer/packages/game/src/import_reducers.rs), which is apparently not auto-generated.

It has many reducers which just check that the caller is an admin and then delegate their work to an internal helper function. I highly recommend creating another attribute proc macro which is added to the helper functions to generate this admin-check-only reducer boilerplate automatically.

The internal helper functions perform actual validation and insert the data into the static data tables.

The reason that the logic is split between the reducers and the helper functions is that the helper functions are also called from another admin-only reducer which "commits" the data from the staging-tables to the static data tables.

As this file is apparently not auto-generated, this means that the "commit_staged_static_data" reducer must be kept in sync with the static data tables, which is a maintenance burden. I recommend generating the reducer like the "import into staging tables" reducers using the build script and moving it to the auto-generated file.

Also it should be thought about splitting this file into multiple files, as it has import reducers not only for static data (are they needed? When do devs need to import into staging tables first and when they don't need to?) but also for the actual game server data.

The `claim_tile_cost` table is missing the `_desc` suffix which is apparently a naming convention for static data tables. I recommend renaming it to `claim_tile_cost_desc` to be consistent with the other static data tables.

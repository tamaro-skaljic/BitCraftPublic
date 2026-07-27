// This file and its entire content was copied from BitCraftServer/packages/game/src/messages/queue.rs to resolve symlinks.
#[spacetimedb::table(name = player_queue_state, public)]
pub struct PlayerQueueState {
    #[primary_key]
    #[auto_inc]
    pub index: u64,
    #[unique]
    pub entity_id: u64,
}

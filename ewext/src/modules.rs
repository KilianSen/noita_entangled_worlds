use eyre::Ok;

pub(crate) mod entity_sync;

pub(crate) trait Module {
    // fn init() -> Self;
    fn on_world_update(&mut self) -> eyre::Result<()> {
        Ok(())
    }
}
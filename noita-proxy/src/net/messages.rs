use bitcode::{Decode, Encode};

use crate::{player_cosmetics::PlayerPngDesc, GameSettings};

use super::{omni::OmniPeerId, world::WorldNetMessage};

#[derive(Debug, PartialEq, Eq)]
pub(crate) enum Destination {
    Peer(OmniPeerId),
    Host,
    Broadcast,
}

pub(crate) struct MessageRequest<T> {
    pub(crate) reliability: tangled::Reliability,
    pub(crate) dst: Destination,
    pub(crate) msg: T,
}

#[derive(Debug, Decode, Encode)]
pub(crate) enum NetMsg {
    Welcome,
    EndRun,
    StartGame { settings: GameSettings },
    ModRaw { data: Vec<u8> },
    ModCompressed { data: Vec<u8> },
    WorldMessage(WorldNetMessage),
    PlayerColor(PlayerPngDesc, bool),
}

impl From<MessageRequest<WorldNetMessage>> for MessageRequest<NetMsg> {
    fn from(value: MessageRequest<WorldNetMessage>) -> Self {
        Self {
            msg: NetMsg::WorldMessage(value.msg),
            reliability: value.reliability,
            dst: value.dst,
        }
    }
}

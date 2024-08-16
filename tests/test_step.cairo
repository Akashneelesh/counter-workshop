use counter::counter::{ICounterDispatcher, ICounterDispatcherTrait};
use snforge_std::{declare, cheatcodes::contract_class::ContractClassTrait};
use kill_switch::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait};
use starknet::{ContractAddress};

#[test]
fn check_stored_counter() {
    let initial_counter = 12;
    let contract_address = deploy_contract(initial_counter, true);
    let dispatcher = ICounterDispatcher { contract_address };
    let stored_counter = dispatcher.get_counter();
    assert!(stored_counter == initial_counter, "Stored value not equal");
}


#[test]
fn test_counter_contract_with_kill_switch_deactivated() {
    let initial_counter = 15;
    let contract_address = deploy_contract(initial_counter, true);
    let dispatcher = ICounterDispatcher { contract_address };

    dispatcher.increase_counter();
    let stored_counter = dispatcher.get_counter();
    assert!(stored_counter == initial_counter + 1, "Value not increased");
}

#[test]
#[should_panic(expected: ("Value not increased",))]
fn test_counter_contract_with_kill_switch_activated() {
    let initial_counter = 15;
    let contract_address = deploy_contract(initial_counter, false);
    let dispatcher = ICounterDispatcher { contract_address };

    dispatcher.increase_counter();
    let stored_counter = dispatcher.get_counter();
    assert!(stored_counter == initial_counter + 1, "Value not increased");
}

pub fn deploy_contract(initial_value: u32, kill_switch: bool) -> ContractAddress {
    let contract = declare("KillSwitch").unwrap();
    let constructor_args = array![kill_switch.into()];
    let (contract_address, _) = contract.deploy(@constructor_args).unwrap();

    let contract = declare("counter_contract").unwrap();
    let constructor_args = array![initial_value.into(), contract_address.into()];
    let (contract_address, _) = contract.deploy(@constructor_args).unwrap();
    contract_address
}

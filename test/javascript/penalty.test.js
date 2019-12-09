import React from 'react';
import ReactDOM from 'react-dom';

import axios from 'axios';

import { mount, configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

import Penalty from 'forkMonitorApp/components/penalty';

jest.mock('axios');

function flushPromises() {
  return new Promise(resolve => setImmediate(resolve));
}

const mockPenalty = {
  "id":1,
  "tx_id":"c64564a132778ba71ffb6188f7b92dac7c5d22afabeaec31f130bbd201ebb1b6",
  "amount":"3608648.0",
  "block":{"height":602649,"timestamp":1573082683,"id":161737,"hash":"00000000000000000008647bf3adffc88909838e32b9543d77086fb8dc6e40a5","work":91.3044362323286,"pool":"Poolin","tx_count":2563,"size":1075431,"first_seen_by":{"id":19,"name_with_version":"Bitcoin Core 0.19."}}
}

const mockPenaltyNoAmount = Object.assign({}, mockPenalty);
mockPenaltyNoAmount.amount = null

describe('component', () => {
  const wrapper = mount(<Penalty penalty={ mockPenalty } />);

  test('should show tx id',() => {
    expect(wrapper.text()).toContain("c64564a132778ba71ffb6188f7b92dac7c5d22afabeaec31f130bbd201ebb1b6");
  });

  test('should show block height',() => {
    expect(wrapper.text()).toContain("602,649");
  });

  test('should show date and time',() => {
    expect(wrapper.text()).toContain("2019-11-06 23:24:43 UTC");
  });

  test('should show amount',() => {
    expect(wrapper.text()).toContain("0.0361 BTC");
  });

  test('should not show amount if absent',() => {
    wrapper.setProps({penalty: mockPenaltyNoAmount});
    expect(wrapper.text()).not.toContain("BTC");
  });

})

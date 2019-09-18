import React from 'react';
import ReactDOM from 'react-dom';

import { mount, configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

import AlertInflation from 'forkMonitorApp/components/alertInflation';

const inflatedBlock = {
        id: 1,
        max_inflation: "25.000000000",
        actual_inflation: "25.01",
        extra_inflation: "0.01",
        comparison_block: {height: 560180, timestamp:1558050809, hash: "0000000000000000002d802cf5fdbbfa94926be7f03b40be75eb6c3c13cbc8e4", first_seen_by: {id:3,name_with_version:"Bitcoin Core 0.18.0"}},
        block: {height:560182, timestamp:1558050809, hash: "0000000000000000002593e1504eb5c5813cac4657d78a04d81ff4e2250d3377", first_seen_by: {id:3,name_with_version:"Bitcoin Core 0.18.0"}},
        node: {id:21,name_with_version:"Bitcoin Unlimited 0.10.6"}
}

test('should show node name', async () => {
  const wrapper = mount(<AlertInflation inflatedBlock={ inflatedBlock } />);
  expect(wrapper.text()).toContain("Bitcoin Unlimited");
});

test('should show inflation amount', async () => {
  const wrapper = mount(<AlertInflation inflatedBlock={ inflatedBlock } />);
  expect(wrapper.text()).toContain("0.01000000 BTC");
});

test('should show height range', async () => {
  const wrapper = mount(<AlertInflation inflatedBlock={ inflatedBlock } />);
  expect(wrapper.text()).toContain("560180");
  expect(wrapper.text()).toContain("560182");
});

test('should show only one height if range is 1 block', async () => {
  inflatedBlock.comparison_block.height = 560181
  inflatedBlock.comparison_block.hash = "0000000000000000002641ea2457674fea1b2fc5fcfe6fde416dca2a0e13aec2"
  const wrapper = mount(<AlertInflation inflatedBlock={ inflatedBlock } />);
  expect(wrapper.text()).not.toContain("560180");
  expect(wrapper.text()).not.toContain("560181");
  expect(wrapper.text()).toContain("560182");
});
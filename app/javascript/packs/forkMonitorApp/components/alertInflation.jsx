import React from 'react';

import {
    UncontrolledAlert
} from 'reactstrap';

import NumberFormat from 'react-number-format';

import NodeName from './nodeName';

class AlertInflation extends React.Component {
  render() {
    const height = this.props.inflatedBlock.block.height;
    return(
      <UncontrolledAlert color="danger">
        <NodeName node={this.props.inflatedBlock.node} /> detected <NumberFormat value={ this.props.inflatedBlock.extra_inflation } displayType={'text'} decimalScale={8} fixedDecimalScale={true} /> BTC extra inflation
        <span> in block </span>
        { this.props.inflatedBlock.block.hash } at height { height }.
        This block was mined by { this.props.inflatedBlock.block.pool ? this.props.inflatedBlock.block.pool : "an unknown pool" }.
        { this.props.inflatedBlock.block.first_seen_by &&
          <span>
            {} It was first seen and accepted as valid by <NodeName node={this.props.inflatedBlock.block.first_seen_by} />.
          </span>
        }
      </UncontrolledAlert>
    );
  }
}
export default AlertInflation

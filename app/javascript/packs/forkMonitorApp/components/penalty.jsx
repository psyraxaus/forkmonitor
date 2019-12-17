import React from 'react';

import Moment from 'react-moment';
import 'moment-timezone'
import NumberFormat from 'react-number-format';

import Explorer from './explorer';

class Penalty extends React.Component {
  render() {
    return(
      <tr className="pullLeft" >
        <td>
          <Moment format="YYYY-MM-DD HH:mm:ss" tz="UTC" parse="X">{this.props.penalty.block.timestamp}</Moment> UTC
        </td>
        <td>
          <NumberFormat value={ this.props.penalty.block.height } displayType={'text'} thousandSeparator={true} />
        </td>
        <td>
          { this.props.penalty.amount &&
            <span>
              <NumberFormat value={ this.props.penalty.amount } displayType={'text'} decimalScale={4} fixedDecimalScale={true} />
            </span>
          }
        </td>
        <td>
          Opening tx: <Explorer blockstream tx={ this.props.penalty.opening_tx_id }/>&nbsp;
          <Explorer btcCom tx={ this.props.penalty.opening_tx_id }/>
        </td>
        <td>
          <Explorer blockstream tx={ this.props.penalty.tx_id }/>&nbsp;
          <Explorer btcCom tx={ this.props.penalty.tx_id }/>
        </td>
      </tr>
    );
  }
}
export default Penalty

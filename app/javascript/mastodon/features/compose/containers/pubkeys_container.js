import React from 'react';
import Button from '../../../components/button';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  pubkeys_placeholder: { id: 'pubkeys_list.placeholder', defaultMessage: 'Keybase username for recpient' },
  pubkeys_add: { id: 'pubkeys_list.add', defaultMessage: 'Add' },
});

const mapStateToProps = (state) => ({
  encrypt: state.getIn(['compose', 'encrypt']),
});

const mapDispatchToProps = dispatch => ({
});

class PubkeysContainer extends React.PureComponent {
  state = {
    inputUsername: '',
    nextPubkeyId: 0,
    pubkeys: [],
  };

  addPubkey = (username) => {
    var pubkeys = this.state.pubkeys;
    pubkeys.push({
      id: this.state.nextPubkeyId++,
      username: username,
    });
    this.setState({ pubkeys: pubkeys });
  }

  handleChange = (e) => {
    this.setState({ inputUsername: e.target.value});
  }

  handleKeyDown = (e) => {
    if (e.keyCode === 13) {
      this.handleSubmit(e);
    }
  }

  handleSubmit = (e) => {
    this.addPubkey(this.state.inputUsername);
    this.setState({ inputUsername: ''});
  }

  static propTypes = {
    encrypt: PropTypes.bool.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    return (
      <div className={`pubkeys-list ${this.props.encrypt ? 'pubkeys-list--visible' : ''}`}>
        <div>
          {this.state.pubkeys.map(k =>
            <div className='pubkeys-list__item' id={k.id}>
              {k.username}
            </div>
          )}
        </div>
        <label>
          <span style={{ display: 'none' }}>{this.props.intl.formatMessage(messages.pubkeys_placeholder)}</span>
          <input placeholder={this.props.intl.formatMessage(messages.pubkeys_placeholder)} value={this.state.inputUsername} onChange={this.handleChange} onKeyDown={this.handleKeyDown} type='text' className='pubkeys-list__input' id='pubkeys-input' />
        </label>
      </div>
    );
  }

}

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(PubkeysContainer));

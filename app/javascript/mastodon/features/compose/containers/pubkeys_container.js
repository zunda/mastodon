import React from 'react';
import Button from '../../../components/button';
import { showAlert } from '../../../actions/alerts';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { injectIntl, defineMessages } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  pubkeys_placeholder: { id: 'pubkeys_list.placeholder', defaultMessage: 'Keybase username for recpient' },
  pubkeys_add: { id: 'pubkeys_list.add', defaultMessage: 'Add' },
});

const mapStateToProps = (state) => ({
  encrypt: state.getIn(['compose', 'encrypt']),
});

const mapDispatchToProps = dispatch => ({
  showAlert: (title, error) => dispatch(showAlert(title, error)),
});

class PubkeysContainer extends React.PureComponent {
  state = {
    inputUsername: '',
    nextPubkeyId: 0,
    pubkeys: [],
  };

  addPubkey = (username) => {
    var pubkeys = this.state.pubkeys;
    if (pubkeys.find((p) => p.username === username)) {
      this.props.showAlert("Duplicate username", username);
      return;
    }
    pubkeys.push({
      id: this.state.nextPubkeyId++,
      username: username,
    });
    this.setState({ inputUsername: '', pubkeys: pubkeys });
  }

  handleChange = (e) => {
    this.setState({ inputUsername: e.target.value});
  }

  handleKeyDown = (e) => {
    if (e.keyCode === 13) {
      this.handleAddSubmit(e);
      e.preventDefault();
    }
  }

  handleAddSubmit = (e) => {
    this.addPubkey(this.state.inputUsername);
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
            <form className='column-inline-form'>
              <IconButton icon='minus' title='remove from recipient' />
              <label>
                <div className='pubkeys-list__item' id={k.id}>
                  {k.username}
                </div>
              </label>
            </form>
          )}
        </div>
        <form className='column-inline-form'>
          <label>
            <span style={{ display: 'none' }}>{this.props.intl.formatMessage(messages.pubkeys_placeholder)}</span>
            <input placeholder={this.props.intl.formatMessage(messages.pubkeys_placeholder)} value={this.state.inputUsername} onChange={this.handleChange} onKeyDown={this.handleKeyDown} type='text' className='pubkeys-list__input' id='pubkeys-input' />
          </label>
          <IconButton icon='plus' title='add to recipient' onClick={this.handleAddSubmit} />
        </form>
      </div>
    );
  }

}

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(PubkeysContainer));

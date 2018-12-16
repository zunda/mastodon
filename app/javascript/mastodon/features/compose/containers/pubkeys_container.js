import React from 'react';
import Button from '../../../components/button';
import { showAlert } from '../../../actions/alerts';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { injectIntl, defineMessages } from 'react-intl';
import IconButton from '../../../components/icon_button';
import { addPubkeyUsername, activatePubkey, deactivatePubkey } from '../../../actions/compose';

const messages = defineMessages({
  pubkeys_placeholder: { id: 'pubkeys_list.placeholder', defaultMessage: 'Keybase username for recpient' },
  pubkeys_add: { id: 'pubkeys_list.add', defaultMessage: 'Add' },
});

const mapStateToProps = (state) => ({
  encrypt: state.getIn(['compose', 'encrypt']),
  nextPubkeyId: state.getIn(['compose', 'nextPubkeyId']),
  pubkeys: state.getIn(['compose', 'pubkeys']),
});

const mapDispatchToProps = dispatch => ({
  showAlert: (title, error) => dispatch(showAlert(title, error)),
  addPubkeyUsername: username => dispatch(addPubkeyUsername(username)),
  activatePubkey: username => dispatch(activatePubkey(username)),
  deactivatePubkey: id => dispatch(deactivatePubkey(id)),
});

class PubkeysContainer extends React.PureComponent {
  state = {
    inputUsername: '',
  };

  addPubkey = (username) => {
    const pubkeys = this.props.pubkeys;
    const existing = pubkeys.find((p) => p.username === username);
    if (existing !== undefined) {
      if (existing.active) {
        this.props.showAlert("Duplicate username", username);
        return;
      } else {
        this.props.activatePubkey(username);
        this.setState({ inputUsername: '' });
      }
    } else {
      this.props.addPubkeyUsername(username);
      this.setState({ inputUsername: '' });
    }
  }

  deactivatePubkey = (id) => {
    this.props.deactivatePubkey(id);
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
    if (this.state.inputUsername.length > 0) {
      this.addPubkey(this.state.inputUsername);
    }
  }

  handleRemove = (e, id) => {
    this.deactivatePubkey(id);
  }

  static propTypes = {
    encrypt: PropTypes.bool.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    return (
      <div className={`pubkeys-list ${this.props.encrypt ? 'pubkeys-list--visible' : ''}`}>
        <div>
          {this.props.pubkeys.filter(k => k.active).map(k =>
            <form className='column-inline-form' key={k.id}>
              <label>
                <div className='pubkeys-list__item' id={k.id}>
                  {k.username}
                </div>
              </label>
              <IconButton icon='minus' title='remove from recipient' onClick={e => this.handleRemove(e, k.id)} key={k.id} />
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

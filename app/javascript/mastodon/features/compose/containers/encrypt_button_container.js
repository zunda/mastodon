import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import IconButton from '../../../components/icon_button';
import { setComposeEncryption } from '../../../actions/compose';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  encrypt: { id: 'compose_form.encrypt.marked', defaultMessage: 'Toot will be encrypted' },
  clearText: { id: 'compose_form.encrypt.unmarked', defaultMessage: 'Toot will be clear text' },
});

const mapStateToProps = (state, { intl }) => ({
  encrypt: state.getIn(['compose', 'encrypt']),
});

const mapDispatchToProps = dispatch => ({

  onClick (flag) {
    dispatch(setComposeEncryption(flag));
  },

});

class EncryptButtonContainer extends React.PureComponent {

  static propTypes = {
    encrypt: PropTypes.bool.isRequired,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { encrypt, onClick, intl } = this.props;

    return (
      <div className='compose-form__encrypt-button'>
        <IconButton
          className='compose-form__encrypt-button__icon'
          title={intl.formatMessage(encrypt ? messages.encrypt : messages.clearText)}
          icon={ this.props.encrypt ? 'lock' : 'unlock' }
          onClick={() => this.props.onClick(!this.props.encrypt)}
          size={18}
          active={encrypt}
          style={{ lineHeight: '27px', height: null }}
          inverted
        />
      </div>
    );
  }

}

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(EncryptButtonContainer));

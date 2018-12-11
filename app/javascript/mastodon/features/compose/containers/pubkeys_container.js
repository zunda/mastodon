import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { injectIntl, defineMessages } from 'react-intl';

const mapStateToProps = (state, { intl }) => ({
  encrypt: state.getIn(['compose', 'encrypt']),
});

const mapDispatchToProps = dispatch => ({
});

class PubkeysContainer extends React.PureComponent {

  static propTypes = {
    encrypt: PropTypes.bool.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    return (
      <div className={`pubkeys-list ${this.props.encrypt ? 'pubkeys-list--visible' : ''}`}>
        <p>Pubkeys of recipients</p>
      </div>
    );
  }

}

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(PubkeysContainer));

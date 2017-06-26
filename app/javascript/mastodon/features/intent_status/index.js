import React from 'react';
import ComposeFormContainer from '../compose/containers/compose_form_container';
import NavigationContainer from '../compose/containers/navigation_container';
import PropTypes from 'prop-types';
import { injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose, changeCompose } from '../../actions/compose';

const mapStateToProps = state => ({
  initialText: state.getIn(['meta', 'intent_status_initial_text']),
});

@connect(mapStateToProps)
@injectIntl
export default class IntentStatus extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    initialText: PropTypes.string,
  };

  componentDidMount () {
    this.props.dispatch(mountCompose());
    if (this.props.initialText) {
      this.props.dispatch(changeCompose(this.props.initialText));
    }
  }

  componentWillUnmount () {
    this.props.dispatch(unmountCompose());
  }

  render () {
    return (
      <div className='intent-status'>
        <NavigationContainer />
        <ComposeFormContainer />
      </div>
    );
  }

}

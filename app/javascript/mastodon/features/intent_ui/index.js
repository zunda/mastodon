import React from 'react';
import Switch from 'react-router-dom/Switch';
import Route from 'react-router-dom/Route';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { debounce } from 'lodash';
import { uploadCompose } from '../../actions/compose';
import IntentStatus from '../../features/intent_status';
import AlertBarContainer from '../../features/ui/containers/alert_bar_container';
import NotificationsContainer from '../../features/ui/containers/notifications_container';
import UploadArea from '../../features/ui/components/upload_area';

@connect()
export default class IntentUI extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
  };

  state = {
    width: window.innerWidth,
    draggingOver: false,
  };

  handleResize = debounce(() => {
    this.setState({ width: window.innerWidth });
  }, 500, {
    trailing: true,
  });

  handleDragEnter = (e) => {
    e.preventDefault();

    if (!this.dragTargets) {
      this.dragTargets = [];
    }

    if (this.dragTargets.indexOf(e.target) === -1) {
      this.dragTargets.push(e.target);
    }

    if (e.dataTransfer && e.dataTransfer.types.includes('Files')) {
      this.setState({ draggingOver: true });
    }
  }

  handleDragOver = (e) => {
    e.preventDefault();
    e.stopPropagation();

    try {
      e.dataTransfer.dropEffect = 'copy';
    } catch (err) {

    }

    return false;
  }

  handleDrop = (e) => {
    e.preventDefault();

    this.setState({ draggingOver: false });

    if (e.dataTransfer && e.dataTransfer.files.length === 1) {
      this.props.dispatch(uploadCompose(e.dataTransfer.files));
    }
  }

  handleDragLeave = (e) => {
    e.preventDefault();
    e.stopPropagation();

    this.dragTargets = this.dragTargets.filter(el => el !== e.target && this.node.contains(el));

    if (this.dragTargets.length > 0) {
      return;
    }

    this.setState({ draggingOver: false });
  }

  closeUploadModal = () => {
    this.setState({ draggingOver: false });
  }

  componentWillMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);
    document.addEventListener('dragend', this.handleDragEnd, false);
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize);
    document.removeEventListener('dragenter', this.handleDragEnter);
    document.removeEventListener('dragover', this.handleDragOver);
    document.removeEventListener('drop', this.handleDrop);
    document.removeEventListener('dragleave', this.handleDragLeave);
    document.removeEventListener('dragend', this.handleDragEnd);
  }

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { draggingOver } = this.state;
    const { children } = this.props;

    return (
      <div className='ui simple-ui' ref={this.setRef}>
        <Switch>
          <Route path='/statuses/new' component={IntentStatus} content={children} />
        </Switch>
        <NotificationsContainer />
        <AlertBarContainer />
        <UploadArea active={draggingOver} onClose={this.closeUploadModal} />
      </div>
    );
  }

}

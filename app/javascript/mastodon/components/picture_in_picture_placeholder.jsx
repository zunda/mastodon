import React from 'react';
import PropTypes from 'prop-types';
import { Icon }  from 'mastodon/components/icon';
import { removePictureInPicture } from 'mastodon/actions/picture_in_picture';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';

class PictureInPicturePlaceholder extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
  };

  handleClick = () => {
    const { dispatch } = this.props;
    dispatch(removePictureInPicture());
  };

  render () {
    return (
      <div className='picture-in-picture-placeholder' role='button' tabIndex={0} onClick={this.handleClick}>
        <Icon id='window-restore' />
        <FormattedMessage id='picture_in_picture.restore' defaultMessage='Put it back' />
      </div>
    );
  }

}

export default connect()(PictureInPicturePlaceholder);

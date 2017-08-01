import { expect } from 'chai';
import { mount } from 'enzyme';
import React from 'react';
import { Provider } from 'react-redux';
import { MemoryRouter, Route } from 'react-router-dom';
import { IntlProvider } from 'react-intl';
import { createStore } from 'redux';

import { hydrateStore } from '../../../../../app/javascript/mastodon/actions/store';
import { changeCompose } from '../../../../../app/javascript/mastodon/actions/compose';
import appReducer from '../../../../../app/javascript/mastodon/reducers';
import messages from '../../../../../app/javascript/mastodon/locales/en.json';

import IntentUI from '../../../../../app/javascript/mastodon/features/intent_ui';

describe('<IntentUI />', () => {
  const mountUI = ({ store, route }) => {
    return mount(
      <IntlProvider locale='en' messages={messages}>
        <Provider store={store}>
          <MemoryRouter
            initialEntries={[route]}
          >
            <Route path='/' component={IntentUI} />
          </MemoryRouter>
        </Provider>
      </IntlProvider>
    );
  };

  const initialText = 'hoge';
  let store, actions;
  beforeEach(() => {
    actions = [];
    store = createStore(appReducer);
    store.dispatch(hydrateStore({
      meta: {
        me: 1,
        app_mode: 'intent',
        is_email_confirmed: true,
        intent_status_initial_text: initialText,
      },
      accounts: {
        '1': {
          header_static: 'http://mastodon.test/headers/original/header.png',
          following_count: 0,
          followers_count: 0,
          display_name: '',
          created_at: '2017-07-25T13:18:31.642Z',
          locked: false,
          header: 'http://mastodon.test/headers/original/header.png',
          url: 'http://mastodon.test/@tomoasleep',
          statuses_count: 0,
          note: '<p></p>',
          acct: 'tomoasleep',
          avatar_static: 'http://mastodon.test/system/accounts/avatars/avatar.png',
          username: 'tomoasleep',
          qiita_username: 'tomoasleep',
          avatar: 'http://mastodon.test/system/accounts/avatars/avatar.png',
          id: 1,
        },
      },
      media_attachments: {
        accept_content_types: [],
      },
      compose: {
        me: 1,
        default_privacy: 'public',
      },
    }));
    store.replaceReducer((state, action) => {
      actions.push(action);
      return state;
    });
  });

  context('when the route is /statuses/new', () => {
    const route = '/statuses/new';

    it('renders a compose form', () => {
      expect(mountUI({ route, store }).find('.compose-form')).to.be.present();
    });

    it('updates text of compose form with initial text', () => {
      mountUI({ route, store });
      expect(actions).to.deep.include(changeCompose(initialText));
    });
  });
});

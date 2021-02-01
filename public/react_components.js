/*  --- Helpful tools ---
      https://material-ui.com/components/buttons/
      https://codesandbox.io/
      https://babeljs.io/
*/


'use strict';

const e = React.createElement;
const { Button, List, ListItem, ListItemAvatar, Avatar, ListItemText, Icon } = MaterialUI;  // MaterialUI components

class TomTest extends React.Component {
  constructor(props) {
    super(props);
    this.state = { liked: false };
  }

  render() {
    if (this.state.liked) {
      return 'You liked this.';
    }

    return React.createElement(
      'button',
      { onClick: () => this.setState({ liked: true }) },
      'Like'
    );
  }
}

class TimeZones extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return React.createElement(List, null, /*#__PURE__*/React.createElement(ListItem, null, /*#__PURE__*/React.createElement(ListItemAvatar, null, /*#__PURE__*/React.createElement(Avatar, null, /*#__PURE__*/React.createElement(Icon, null, "public"))), /*#__PURE__*/React.createElement(ListItemText, {
      primary: "Example Timezone",
      secondary: "current time"
    })), /*#__PURE__*/React.createElement(ListItem, null, /*#__PURE__*/React.createElement(ListItemAvatar, null, /*#__PURE__*/React.createElement(Avatar, null, /*#__PURE__*/React.createElement(Icon, null, "public"))), /*#__PURE__*/React.createElement(ListItemText, {
      primary: "Example Timezone",
      secondary: "Jan 7, 2014"
    })), /*#__PURE__*/React.createElement(ListItem, null, /*#__PURE__*/React.createElement(ListItemAvatar, null, /*#__PURE__*/React.createElement(Avatar, null, /*#__PURE__*/React.createElement(Icon, null, "public"))), /*#__PURE__*/React.createElement(ListItemText, {
      primary: "Example Timezone",
      secondary: "July 20, 2014"
    })));
  }
}

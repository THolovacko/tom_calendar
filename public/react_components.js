/*  --- Helpful tools ---
      https://material-ui.com/components/buttons/
      https://codesandbox.io/
      https://babeljs.io/
*/


'use strict';

const { Button, List, ListItem, ListItemAvatar, Avatar, ListItemText, Icon, FormControl, FormLabel, FormGroup, FormControlLabel, Checkbox, Switch, TextField, CircularProgress, Card, CardActionArea, CardMedia, CardContent, Typography, CardActions, CardHeader, IconButton, Menu, MenuItem, Snackbar, CloseIcon, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions } = MaterialUI;  // MaterialUI components

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
    const all_time_zones = ["Africa/Abidjan", "Africa/Accra", "Africa/Algiers", "Africa/Bissau", "Africa/Cairo", "Africa/Casablanca", "Africa/Ceuta", "Africa/El_Aaiun", "Africa/Johannesburg", "Africa/Juba", "Africa/Khartoum", "Africa/Lagos", "Africa/Maputo", "Africa/Monrovia", "Africa/Nairobi", "Africa/Ndjamena", "Africa/Sao_Tome", "Africa/Tripoli", "Africa/Tunis", "Africa/Windhoek", "America/Adak", "America/Anchorage", "America/Araguaina", "America/Argentina/Buenos_Aires", "America/Argentina/Catamarca", "America/Argentina/Cordoba", "America/Argentina/Jujuy", "America/Argentina/La_Rioja", "America/Argentina/Mendoza", "America/Argentina/Rio_Gallegos", "America/Argentina/Salta", "America/Argentina/San_Juan", "America/Argentina/San_Luis", "America/Argentina/Tucuman", "America/Argentina/Ushuaia", "America/Asuncion", "America/Atikokan", "America/Bahia", "America/Bahia_Banderas", "America/Barbados", "America/Belem", "America/Belize", "America/Blanc-Sablon", "America/Boa_Vista", "America/Bogota", "America/Boise", "America/Cambridge_Bay", "America/Campo_Grande", "America/Cancun", "America/Caracas", "America/Cayenne", "America/Chicago", "America/Chihuahua", "America/Costa_Rica", "America/Creston", "America/Cuiaba", "America/Curacao", "America/Danmarkshavn", "America/Dawson", "America/Dawson_Creek", "America/Denver", "America/Detroit", "America/Edmonton", "America/Eirunepe", "America/El_Salvador", "America/Fort_Nelson", "America/Fortaleza", "America/Glace_Bay", "America/Goose_Bay", "America/Grand_Turk", "America/Guatemala", "America/Guayaquil", "America/Guyana", "America/Halifax", "America/Havana", "America/Hermosillo", "America/Indiana/Indianapolis", "America/Indiana/Knox", "America/Indiana/Marengo", "America/Indiana/Petersburg", "America/Indiana/Tell_City", "America/Indiana/Vevay", "America/Indiana/Vincennes", "America/Indiana/Winamac", "America/Inuvik", "America/Iqaluit", "America/Jamaica", "America/Juneau", "America/Kentucky/Louisville", "America/Kentucky/Monticello", "America/La_Paz", "America/Lima", "America/Los_Angeles", "America/Maceio", "America/Managua", "America/Manaus", "America/Martinique", "America/Matamoros", "America/Mazatlan", "America/Menominee", "America/Merida", "America/Metlakatla", "America/Mexico_City", "America/Miquelon", "America/Moncton", "America/Monterrey", "America/Montevideo", "America/Nassau", "America/New_York", "America/Nipigon", "America/Nome", "America/Noronha", "America/North_Dakota/Beulah", "America/North_Dakota/Center", "America/North_Dakota/New_Salem", "America/Nuuk", "America/Ojinaga", "America/Panama", "America/Pangnirtung", "America/Paramaribo", "America/Phoenix", "America/Port-au-Prince", "America/Port_of_Spain", "America/Porto_Velho", "America/Puerto_Rico", "America/Punta_Arenas", "America/Rainy_River", "America/Rankin_Inlet", "America/Recife", "America/Regina", "America/Resolute", "America/Rio_Branco", "America/Santarem", "America/Santiago", "America/Santo_Domingo", "America/Sao_Paulo", "America/Scoresbysund", "America/Sitka", "America/St_Johns", "America/Swift_Current", "America/Tegucigalpa", "America/Thule", "America/Thunder_Bay", "America/Tijuana", "America/Toronto", "America/Vancouver", "America/Whitehorse", "America/Winnipeg", "America/Yakutat", "America/Yellowknife", "Antarctica/Casey", "Antarctica/Davis", "Antarctica/DumontDUrville", "Antarctica/Macquarie", "Antarctica/Mawson", "Antarctica/Palmer", "Antarctica/Rothera", "Antarctica/Syowa", "Antarctica/Troll", "Antarctica/Vostok", "Asia/Almaty", "Asia/Amman", "Asia/Anadyr", "Asia/Aqtau", "Asia/Aqtobe", "Asia/Ashgabat", "Asia/Atyrau", "Asia/Baghdad", "Asia/Baku", "Asia/Bangkok", "Asia/Barnaul", "Asia/Beirut", "Asia/Bishkek", "Asia/Brunei", "Asia/Chita", "Asia/Choibalsan", "Asia/Colombo", "Asia/Damascus", "Asia/Dhaka", "Asia/Dili", "Asia/Dubai", "Asia/Dushanbe", "Asia/Famagusta", "Asia/Gaza", "Asia/Hebron", "Asia/Ho_Chi_Minh", "Asia/Hong_Kong", "Asia/Hovd", "Asia/Irkutsk", "Asia/Jakarta", "Asia/Jayapura", "Asia/Jerusalem", "Asia/Kabul", "Asia/Kamchatka", "Asia/Karachi", "Asia/Kathmandu", "Asia/Khandyga", "Asia/Kolkata", "Asia/Krasnoyarsk", "Asia/Kuala_Lumpur", "Asia/Kuching", "Asia/Macau", "Asia/Magadan", "Asia/Makassar", "Asia/Manila", "Asia/Nicosia", "Asia/Novokuznetsk", "Asia/Novosibirsk", "Asia/Omsk", "Asia/Oral", "Asia/Pontianak", "Asia/Pyongyang", "Asia/Qatar", "Asia/Qostanay", "Asia/Qyzylorda", "Asia/Riyadh", "Asia/Sakhalin", "Asia/Samarkand", "Asia/Seoul", "Asia/Shanghai", "Asia/Singapore", "Asia/Srednekolymsk", "Asia/Taipei", "Asia/Tashkent", "Asia/Tbilisi", "Asia/Tehran", "Asia/Thimphu", "Asia/Tokyo", "Asia/Tomsk", "Asia/Ulaanbaatar", "Asia/Urumqi", "Asia/Ust-Nera", "Asia/Vladivostok", "Asia/Yakutsk", "Asia/Yangon", "Asia/Yekaterinburg", "Asia/Yerevan", "Atlantic/Azores", "Atlantic/Bermuda", "Atlantic/Canary", "Atlantic/Cape_Verde", "Atlantic/Faroe", "Atlantic/Madeira", "Atlantic/Reykjavik", "Atlantic/South_Georgia", "Atlantic/Stanley", "Australia/Adelaide", "Australia/Brisbane", "Australia/Broken_Hill", "Australia/Currie", "Australia/Darwin", "Australia/Eucla", "Australia/Hobart", "Australia/Lindeman", "Australia/Lord_Howe", "Australia/Melbourne", "Australia/Perth", "Australia/Sydney", "Europe/Amsterdam", "Europe/Andorra", "Europe/Astrakhan", "Europe/Athens", "Europe/Belgrade", "Europe/Berlin", "Europe/Brussels", "Europe/Bucharest", "Europe/Budapest", "Europe/Chisinau", "Europe/Copenhagen", "Europe/Dublin", "Europe/Gibraltar", "Europe/Helsinki", "Europe/Istanbul", "Europe/Kaliningrad", "Europe/Kiev", "Europe/Kirov", "Europe/Lisbon", "Europe/London", "Europe/Luxembourg", "Europe/Madrid", "Europe/Malta", "Europe/Minsk", "Europe/Monaco", "Europe/Moscow", "Europe/Oslo", "Europe/Paris", "Europe/Prague", "Europe/Riga", "Europe/Rome", "Europe/Samara", "Europe/Saratov", "Europe/Simferopol", "Europe/Sofia", "Europe/Stockholm", "Europe/Tallinn", "Europe/Tirane", "Europe/Ulyanovsk", "Europe/Uzhgorod", "Europe/Vienna", "Europe/Vilnius", "Europe/Volgograd", "Europe/Warsaw", "Europe/Zaporozhye", "Europe/Zurich", "Indian/Chagos", "Indian/Christmas", "Indian/Cocos", "Indian/Kerguelen", "Indian/Mahe", "Indian/Maldives", "Indian/Mauritius", "Indian/Reunion", "Pacific/Apia", "Pacific/Auckland", "Pacific/Bougainville", "Pacific/Chatham", "Pacific/Chuuk", "Pacific/Easter", "Pacific/Efate", "Pacific/Enderbury", "Pacific/Fakaofo", "Pacific/Fiji", "Pacific/Funafuti", "Pacific/Galapagos", "Pacific/Gambier", "Pacific/Guadalcanal", "Pacific/Guam", "Pacific/Honolulu", "Pacific/Kiritimati", "Pacific/Kosrae", "Pacific/Kwajalein", "Pacific/Majuro", "Pacific/Marquesas", "Pacific/Nauru", "Pacific/Niue", "Pacific/Norfolk", "Pacific/Noumea", "Pacific/Pago_Pago", "Pacific/Palau", "Pacific/Pitcairn", "Pacific/Pohnpei", "Pacific/Port_Moresby", "Pacific/Rarotonga", "Pacific/Tahiti", "Pacific/Tarawa", "Pacific/Tongatapu", "Pacific/Wake", "Pacific/Wallis", "UTC"];

    function parseTimeZoneParts(target_time_zone) {
      var parts = target_time_zone.split("/");
      if (parts.length >= 3) {
        parts[0] = `${parts[1]}, ${parts[0]}`;
      }
      return [parts[0].replace(/_/g, " "), parts[parts.length - 1].replace(/_/g, " ") + " Time"];
    }

    const list_items = all_time_zones.map(time_zone => /*#__PURE__*/React.createElement(ListItem, {
      key: time_zone.toString(),
      value: time_zone,
      button: true,
      onClick: function(ev) { handleTimeZonesClick(time_zone) } /* handler function defined in dashboard */
    },
    /*#__PURE__*/React.createElement(ListItemAvatar, null, /*#__PURE__*/React.createElement(Avatar, null, /*#__PURE__*/React.createElement(Icon, {
      fontSize: "inherit"
    }, "public"))), /*#__PURE__*/React.createElement(ListItemText, {
      primary: parseTimeZoneParts(time_zone)[1],
      secondary: parseTimeZoneParts(time_zone)[0]
    })));
    return /*#__PURE__*/React.createElement(List, {
      disablePadding: true
    }, list_items);
 }
}

class ToggleSwitch extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return /*#__PURE__*/React.createElement(Switch, {
      disableRipple: true,
      defaultChecked: is_general_event,
      onChange: handleToggleSwitchChange,
      color: "primary"
    });
  }
}

class Spinner extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return /*#__PURE__*/React.createElement(CircularProgress, { className: "spinner_circle" });
  }
}

class EventCard extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return /*#__PURE__*/React.createElement(Card, {
        variant: "elevation",
        square: true
      }, /*#__PURE__*/React.createElement(CardHeader, {
        avatar: /*#__PURE__*/React.createElement(Avatar, {
          id: "avatar_" + this.props.container_id,
          variant: "circle",
          alt: this.props.user_name,
          src: this.props.user_avatar,
          onClick: function(ev) { handleEventCardAvatarClick(ev) } /* handler function defined in dashboard */
        }),
        title: this.props.user_name,
        action: /*#__PURE__*/React.createElement(Icon, {
          id: "options_" + this.props.container_id,
          "aria-label": "options",
          fontSize: "inherit",
          style: {
            marginTop: '7px',
            marginRight: '8px'
          },
          onClick: function(ev) { setCardOptionsMenuAnchor(ev); handleEventCardOptionsClick(ev) } /* handler function defined in dashboard */
        }, "more_vert")
      }), /*#__PURE__*/React.createElement(CardActionArea, null, /*#__PURE__*/React.createElement(CardMedia, {
        component: "img",
        alt: this.props.title,
        image: this.props.image,
        title: this.props.title,
        onClick: function(ev) { handleEventCardImageClick(ev) } /* handler function defined in dashboard */
      }), /*#__PURE__*/React.createElement(CardContent, null, /*#__PURE__*/React.createElement(Typography, {
        gutterBottom: true,
        variant: "h6",
        component: "h2",
        style: {
          float: 'left'
        }
      }, this.props.title), /*#__PURE__*/React.createElement(CardActions, {
        style: {
          float: 'right'
        }
      }, /*#__PURE__*/React.createElement(Button, {
        id: "reminder_btn_" + this.props.container_id,
        size: "medium",
        color: "primary",
        onClick: function(ev) { handleEventCardSetReminderClick(ev) } /* handler function defined in dashboard */
      }, "Set reminder")))), /*#__PURE__*/React.createElement(CardActionArea, null, /*#__PURE__*/React.createElement(Typography, {
        gutterBottom: true,
        className: "date_range_txt"
      }, /*#__PURE__*/React.createElement(Icon, {
        "aria-label": "date range",
        fontSize: "inherit"
      }, "date_range"), this.props.date_time), /*#__PURE__*/React.createElement(Typography, {
        gutterBottom: true,
        className: "location_txt"
      }, /*#__PURE__*/React.createElement(Icon, {
        "aria-label": "location",
        fontSize: "inherit"
      }, "location_on"), this.props.location), /*#__PURE__*/React.createElement(Typography, {
        gutterBottom: true,
        className: "description_txt"
      }, /*#__PURE__*/React.createElement(Icon, {
        "aria-label": "description",
        fontSize: "inherit"
      }, "notes"), this.props.description)));
  }
}

var current_option_container_id = '';
var setCardOptionsMenuAnchor;
function CardOptionsMenu() {
  const [anchorEl, setAnchorEl] = React.useState(null);

  const handleClick = event => {
    setAnchorEl(event.currentTarget);
    current_option_container_id = event.currentTarget.id.replace('options_event_card_react_container_','');
  };
  setCardOptionsMenuAnchor = handleClick;
  
  const handleClose = event => {
    setAnchorEl(null);
    handleOptionClick(event);
  };

  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(Menu, {
    id: "card-options",
    anchorEl: anchorEl,
    keepMounted: true,
    disableAutoFocusItem: true,
    open: Boolean(anchorEl),
    onClose: handleClose
  }, /*#__PURE__*/React.createElement(MenuItem, {
    className: "copy_link_option_txt",
    onClick: handleClose
  }, "Copy link"), /*#__PURE__*/React.createElement(MenuItem, {
    className: "edit_option_txt",
    onClick: handleClose
  }, "Edit"), /*#__PURE__*/React.createElement(MenuItem, {
    className: "delete_option_txt",
    onClick: handleClose
  }, "Delete"), /*#__PURE__*/React.createElement(MenuItem, {
    className: "report_option_txt",
    onClick: handleClose
  }, "Report")));
}

var snackbar_notification_message = '';
var snackbarNotify;
function SimpleSnackbar() {
  const [open, setOpen] = React.useState(false);

  const handleClick = () => {
    setOpen(true);
  };
  snackbarNotify = handleClick;

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      setOpen(false);
      return;
    }
    setOpen(false);
  };

  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(Snackbar, {
    anchorOrigin: {
      vertical: 'bottom',
      horizontal: 'center'
    },
    open: open,
    autoHideDuration: 1500,
    onClose: handleClose,
    message: snackbar_notification_message
  }));
}

var alert_dialog_notification_message = "";
var alert_dialog_title = "";
var alert_ok_text = "OK";
var alert_cancel_text = "Cancel";
var alert_dialog_decision = "Cancel";
var alertDialog;
var alertDialogCallback = function() {};
function AlertDialog() {
  const [open, setOpen] = React.useState(false);

  const handleClickOpen = () => {
    setOpen(true);
  };
  alertDialog = handleClickOpen;

  const handleClose = event => {
    setOpen(false);

    if (event.currentTarget.id == 'ok_btn') {
      alert_dialog_decision = 'OK';
    } else {
      alert_dialog_decision = 'Cancel';
    }
    alertDialogCallback();
    alertDialogCallback = function() {};
  };

  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(Dialog, {
    open: open,
    onClose: handleClose,
    "aria-labelledby": "alert-dialog-title",
    "aria-describedby": "alert-dialog-description"
  }, /*#__PURE__*/React.createElement(DialogTitle, {
    id: "alert-dialog-title"
  }, alert_dialog_title), /*#__PURE__*/React.createElement(DialogContent, null, /*#__PURE__*/React.createElement(DialogContentText, {
    id: "alert-dialog-description"
  }, alert_dialog_notification_message)), /*#__PURE__*/React.createElement(DialogActions, null, /*#__PURE__*/React.createElement(Button, {
    onClick: handleClose,
    id: "cancel_btn",
    color: "primary"
  }, alert_cancel_text), /*#__PURE__*/React.createElement(Button, {
    onClick: handleClose,
    color: "primary",
    id: "ok_btn",
    autoFocus: true
  }, alert_ok_text))));
}

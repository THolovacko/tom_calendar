import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import Avatar from '@material-ui/core/Avatar';
import CardActionArea from '@material-ui/core/CardActionArea';
import CardHeader from '@material-ui/core/CardHeader';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import IconButton from '@material-ui/core/IconButton';
import Icon from "@material-ui/core/Icon";

const useStyles = makeStyles({
  root: {
    maxWidth: 550,
  },
});

export default function ImgMediaCard() {
  const classes = useStyles();

  return (
    <Card className={classes.root} variant="outlined" square>
      <CardHeader avatar={<Avatar aria-label="recipe">T</Avatar>} title="tom.holovacko" action={<Icon aria-label="options" fontSize="inherit" style={{marginTop:'14px',marginRight:'2px'}}>more_vert</Icon>}></CardHeader>
      <CardActionArea>
        <CardMedia
          component="img"
          alt="Arfest"
          image="https://tomcalendareventimages.s3.us-east-2.amazonaws.com/c2cbadab55aa9bde06ee853d490952b29d8dfa594f0bac59fb68c09d5af1f93e.jpg"
          title="Artfest"
        />
        <CardContent>
          <Typography gutterBottom variant="h6" component="h2" style={{float:'left'}}>
            Artfest
          </Typography>
          <CardActions style={{float:'right'}}>
        <Button size="large" color="primary">
          Set reminder
        </Button>
          </CardActions>
        </CardContent>
      </CardActionArea>
      <CardActionArea>
        <Typography gutterBottom>
          <Icon aria-label="options" fontSize="inherit">date_range</Icon>
            May 12, 2021 - May 15, 2021 from 9am - 11pm every week on sunday
        </Typography>
        <Typography gutterBottom>
          <Icon aria-label="options" fontSize="inherit">location_on</Icon>
          Madison Square Garden, Pennsylvania Plaza, New York, NY, USA
        </Typography>
        <Typography gutterBottom>
          <Icon aria-label="options" fontSize="inherit">notes</Icon>
          The film reboots the Batman film series, telling the origin story of Bruce Wayne from the death of his parents to his journey to become Batman and his fight to stop Ra's al Ghul and the Scarecrow from plunging Gotham City into chaos
        </Typography>
      </CardActionArea>
    </Card>
  );
}

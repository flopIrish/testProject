package com.test.irishrailrt;

import android.util.Xml;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class TrainMvtXmlParser {

    private static final String ns = null;

    public List<EntryMvt> parse(InputStream in) throws XmlPullParserException, IOException {
        try {
            XmlPullParser parser = Xml.newPullParser();
            parser.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false);
            parser.setInput(in, null);
            parser.nextTag();
            return readFeed(parser);
        } finally {
            in.close();
        }
    }

    private List<EntryMvt> readFeed(XmlPullParser parser) throws XmlPullParserException, IOException {
        List<EntryMvt> entries = new ArrayList<EntryMvt>();

        parser.require(XmlPullParser.START_TAG, ns, "ArrayOfObjTrainMovements");
        while (parser.next() != XmlPullParser.END_TAG) {
            if (parser.getEventType() != XmlPullParser.START_TAG) {
                continue;
            }
            String name = parser.getName();
            // Starts by looking for the objStationData tag
            if (name.equals("objTrainMovements")) {
                entries.add(readEntryMvt(parser));
            } else {
                skip(parser);
            }
        }
        return entries;
    }

    // This class represents a single entry (post) in the XML feed.
    // It includes the data members "title," "link," and "summary."
    public static class EntryMvt {
        public final String TrainCode;
        public final String LocationCode;
        public final String ExpectedDeparture;
        public final String ScheduledDeparture;
        public final String ExpectedArrival;
        public final String ScheduledArrival;

        private EntryMvt(String TrainCode, String LocationCode, String ExpectedDeparture,String ScheduledDeparture,String ExpectedArrival,String ScheduledArrival) {
            this.TrainCode = TrainCode;
            this.LocationCode = LocationCode;
            this.ExpectedDeparture = ExpectedDeparture;
            this.ScheduledDeparture = ScheduledDeparture;
            this.ExpectedArrival = ExpectedArrival;
            this.ScheduledArrival = ScheduledArrival;
        }
    }

    // Parses the contents of an entry. If it encounters a TrainCode, Direction, Destination or TrainType tag, hands them
    // off
    // to their respective read methods for processing. Otherwise, skips the tag.
    private EntryMvt readEntryMvt(XmlPullParser parser) throws XmlPullParserException, IOException {
        parser.require(XmlPullParser.START_TAG, ns, "objTrainMovements");
        String trainCode = null;
        String locationCode = null;
        String expectedDeparture = null;
        String scheduledDeparture = null;
        String expectedArrival = null;
        String scheduledArrival = null;
        while (parser.next() != XmlPullParser.END_TAG) {
            if (parser.getEventType() != XmlPullParser.START_TAG) {
                continue;
            }
            String name = parser.getName();
            if (name.equals("TrainCode")) {
                trainCode = readTrainCode(parser);
            } else if (name.equals("LocationCode")) {
                locationCode = readLocationCode(parser);
            } else if (name.equals("ExpectedDeparture")) {
                expectedDeparture = readExpectedDeparture(parser);
            } else if (name.equals("ScheduledDeparture")) {
                scheduledDeparture = readScheduledDeparture(parser);
            } else if (name.equals("ExpectedArrival")) {
            	expectedArrival = readExpectedArrival(parser);
            } else if (name.equals("ScheduledArrival")) {
            	scheduledArrival = readScheduledArrival(parser);
            } else {
                skip(parser);
            }
        }
        return new EntryMvt(trainCode, locationCode, expectedDeparture, scheduledDeparture, expectedArrival, scheduledArrival);
    }

    // Processes Train Code tags in the feed.
    private String readTrainCode(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "TrainCode");
        String trainCode = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "TrainCode");
        return trainCode;
    }

    // Processes LocationCode tags in the feed.
    private String readLocationCode(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "LocationCode");
        String direction = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "LocationCode");
        return direction;
    }

    // Processes ExpectedDeparture tags in the feed.
    private String readExpectedDeparture(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "ExpectedDeparture");
        String destination = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "ExpectedDeparture");
        return destination;
    }
    
    // Processes ScheduledDeparture tags in the feed.
    private String readScheduledDeparture(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "ScheduledDeparture");
        String trainType = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "ScheduledDeparture");
        return trainType;
    }
    
    // Processes ExpectedArrival tags in the feed.
    private String readExpectedArrival(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "ExpectedArrival");
        String destination = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "ExpectedArrival");
        return destination;
    }
    
    // Processes ScheduledArrival tags in the feed.
    private String readScheduledArrival(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "ScheduledArrival");
        String trainType = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "ScheduledArrival");
        return trainType;
    }

    // For all tags extracts their text values.
    private String readText(XmlPullParser parser) throws IOException, XmlPullParserException {
        String result = "";
        if (parser.next() == XmlPullParser.TEXT) {
            result = parser.getText();
            parser.nextTag();
        }
        return result;
    }

    // Skips tags the parser isn't interested in. Uses depth to handle nested tags. i.e.,
    // if the next tag after a START_TAG isn't a matching END_TAG, it keeps going until it
    // finds the matching END_TAG (as indicated by the value of "depth" being 0).
    private void skip(XmlPullParser parser) throws XmlPullParserException, IOException {
        if (parser.getEventType() != XmlPullParser.START_TAG) {
            throw new IllegalStateException();
        }
        int depth = 1;
        while (depth != 0) {
            switch (parser.next()) {
            case XmlPullParser.END_TAG:
                    depth--;
                    break;
            case XmlPullParser.START_TAG:
                    depth++;
                    break;
            }
        }
    }
	
}

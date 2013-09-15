package com.test.irishrailrt;

import android.util.Xml;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;


public class TrainCodeXmlParser {
    private static final String ns = null;

    public List<Entry> parse(InputStream in) throws XmlPullParserException, IOException {
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

    private List<Entry> readFeed(XmlPullParser parser) throws XmlPullParserException, IOException {
        List<Entry> entries = new ArrayList<Entry>();

        parser.require(XmlPullParser.START_TAG, ns, "ArrayOfObjStationData");
        while (parser.next() != XmlPullParser.END_TAG) {
            if (parser.getEventType() != XmlPullParser.START_TAG) {
                continue;
            }
            String name = parser.getName();
            // Starts by looking for the objStationData tag
            if (name.equals("objStationData")) {
                entries.add(readEntry(parser));
            } else {
                skip(parser);
            }
        }
        return entries;
    }

    // This class represents a single entry (post) in the XML feed.
    // It includes the data members "title," "link," and "summary."
    public static class Entry {
        public final String TrainCode;
        public final String Direction;
        public final String Destination;
        public final String TrainType;

        private Entry(String TrainCode, String Direction, String Destination,String TrainType) {
            this.TrainCode = TrainCode;
            this.Direction = Direction;
            this.Destination = Destination;
            this.TrainType = TrainType;
        }
    }

    // Parses the contents of an entry. If it encounters a TrainCode, Direction, Destination or TrainType tag, hands them
    // off
    // to their respective read methods for processing. Otherwise, skips the tag.
    private Entry readEntry(XmlPullParser parser) throws XmlPullParserException, IOException {
        parser.require(XmlPullParser.START_TAG, ns, "objStationData");
        String trainCode = null;
        String direction = null;
        String destination = null;
        String trainType = null;
        while (parser.next() != XmlPullParser.END_TAG) {
            if (parser.getEventType() != XmlPullParser.START_TAG) {
                continue;
            }
            String name = parser.getName();
            if (name.equals("TrainCode")) {
                trainCode = readTrainCode(parser);
            } else if (name.equals("Direction")) {
                direction = readDirection(parser);
            } else if (name.equals("Destination")) {
                destination = readDestination(parser);
            } else if (name.equals("TrainType")) {
                trainType = readTrainType(parser);
            } else {
                skip(parser);
            }
        }
        return new Entry(trainCode, direction, destination, trainType);
    }

    // Processes Train Code tags in the feed.
    private String readTrainCode(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "TrainCode");
        String trainCode = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "TrainCode");
        return trainCode;
    }

    // Processes Direction tags in the feed.
    private String readDirection(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "Direction");
        String direction = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "Direction");
        return direction;
    }

    // Processes Destination tags in the feed.
    private String readDestination(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "Destination");
        String destination = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "Destination");
        return destination;
    }
    
    // Processes Train TRype tags in the feed.
    private String readTrainType(XmlPullParser parser) throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, ns, "Traintype");
        String trainType = readText(parser);
        parser.require(XmlPullParser.END_TAG, ns, "Traintype");
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

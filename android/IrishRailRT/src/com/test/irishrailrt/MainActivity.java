package com.test.irishrailrt;

import android.os.Bundle;
import android.app.Activity;
import android.util.Log;
import android.view.Menu;
import android.os.AsyncTask;

import org.xmlpull.v1.XmlPullParserException;

import com.test.irishrailrt.TrainCodeXmlParser.Entry;
import com.test.irishrailrt.TrainMvtXmlParser.EntryMvt;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Calendar;
import java.util.List;


public class MainActivity extends Activity {
	public String myTrainCode;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
	super.onCreate(savedInstanceState);
	setContentView(R.layout.activity_main);
}

   @Override
    public void onStart() {
        super.onStart();

        int hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);
        if(hour > 12) {
        	//afternoon
        	//loads data for TrainCode
        	Log.w("IrishRailRT","afternoon");
        	loadTrainCodeData("SKILL");
        } else {
        	//morning
        	//loads data for TrainCode
        	Log.w("IrishRailRT","morning");
        	loadTrainCodeData("ARKLW");
        }
    }

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}
	
    // Uses AsyncTask subclass to download the XML data from irish rail API
	
	// Work to find Train Code of train starting in StationCode
	//
    private void loadTrainCodeData(String stationCode) {
    	Log.w("IrishRailRT","loadTrainCodeData");
    	Log.w("IrishRailRT",stationCode);
    	String myUrl = String.format("http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=%s",stationCode);
        // AsyncTask subclass
        new DownloadXmlTaskTrainCode().execute(myUrl, stationCode);
    }
    
    // Implementation of AsyncTask used to download XML
    private class DownloadXmlTaskTrainCode extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... urls) {
            try {
                return loadXmlTrainCodeFromNetwork(urls[0],urls[1]);
            } catch (IOException e) {
                return getResources().getString(R.string.connection_error);
            } catch (XmlPullParserException e) {
                return getResources().getString(R.string.xml_error);
            }
        }

    }

    // Uploads data from Irish rail API
    private String loadXmlTrainCodeFromNetwork(String urlString, String stationCode) throws XmlPullParserException, IOException {
    	Log.w("IrishRailRT","loadXmlTrainCodeFromNetwork");
        InputStream stream = null;
        TrainCodeXmlParser trainCodeXmlParser = new TrainCodeXmlParser();
        List<Entry> entries = null;
        
        try {
            stream = downloadUrl(urlString);
            entries = trainCodeXmlParser.parse(stream);
        // Makes sure that the InputStream is closed after the app is
        // finished using it.
        } finally {
            if (stream != null) {
                stream.close();
            }
        }

        // 1 - if we are on a Journey from Shankill to Arklow via Bray, Direction must be Southbound for train from Shankill to Bray
        // 2 - if we are on a Journey from Arklow to Shankill via Bray, Direction must be Northbound for train from Arklow to Bray
        for (Entry entry : entries) {
            String myDirection = entry.Direction;
            Log.w("IrishRailRT",entry.Direction);
            if(stationCode == "SKILL") {
            	if(myDirection == "Southbound") {            		
            		//load data for this trainCode

            		Log.w("irishrailRT",stationCode);
            		Log.w("irishRailRT",entry.TrainCode);
            		loadTrainMvtData(entry.TrainCode);
            		loadTrainCodeData("BRAY");
            		break;
            	}
            } else if(stationCode == "ARKLW") {
            	if(myDirection == "Northbound") {
            		//load data for this trainCode

            		Log.w("irishrailRT",stationCode);
            		Log.w("irishRailRT",entry.TrainCode);
            		loadTrainMvtData(entry.TrainCode);
            		loadTrainCodeData("BRAY");
            		break; 
            	}
            } else  if(stationCode == "BRAY") {
            	int hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);
                if(hour > 12) {
                	if(myDirection == "Southbound") {
                		//load data for this trainCode

                		Log.w("irishrailRT",stationCode);
                		Log.w("irishRailRT",entry.TrainCode);
                		loadTrainMvtData(entry.TrainCode);
                		//load all entries
                	}
                } else {
                	if(myDirection == "Northbound") {
                		//load data for this trainCode

                		Log.w("irishrailRT",stationCode);
                		Log.w("irishRailRT",entry.TrainCode);
                		loadTrainMvtData(entry.TrainCode);
                		//load all entries
                	}
                }
            }
        }
        return null;
    }
    
    // Work to find the data for the selected trainCode
    //
    private void loadTrainMvtData(String trainCode) {
    	String myUrl = String.format("http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=%s&TrainDate=",trainCode);
        // AsyncTask subclass
        new DownloadXmlTaskTrainMvt().execute(myUrl, trainCode);
    }
    
    // Implementation of AsyncTask used to download XML
    private class DownloadXmlTaskTrainMvt extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... urls) {
            try {
                return loadXmlTrainMvtFromNetwork(urls[0],urls[1]);
            } catch (IOException e) {
                return getResources().getString(R.string.connection_error);
            } catch (XmlPullParserException e) {
                return getResources().getString(R.string.xml_error);
            }
        }

    }

    // Uploads from irish rail API
    private String loadXmlTrainMvtFromNetwork(String urlString, String stationCode) throws XmlPullParserException, IOException {
        InputStream stream = null;
        TrainMvtXmlParser trainMvtXmlParser = new TrainMvtXmlParser();
        List<EntryMvt> entries = null;
        
        try {
            stream = downloadUrl(urlString);
            entries = trainMvtXmlParser.parse(stream);
        // Makes sure that the InputStream is closed after the app is
        // finished using it.
        } finally {
            if (stream != null) {
                stream.close();
            }
        }

        // 1 - if we are on a Journey from Shankill to Arklow via Bray, Direction must be Southbound for train from Shankill to Bray
        // 2 - if we are on a Journey from Arklow to Shankill via Bray, Direction must be Northbound for train from Arklow to Bray
        for (EntryMvt entrymvt : entries) {
 
        	
        	
        }
        return null;
    }
    

    // Given a string representation of a URL, sets up a connection and gets
    // an input stream.
    private InputStream downloadUrl(String urlString) throws IOException {
    	Log.w("IrishRailRT","downloadUrl");
    	Log.w("IrishRailRT",urlString);
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setReadTimeout(10000 /* milliseconds */);
        conn.setConnectTimeout(15000 /* milliseconds */);
        conn.setRequestMethod("GET");
        conn.setDoInput(true);
        // Starts the query
        conn.connect();
        InputStream stream = conn.getInputStream();
        return stream;
    }

}

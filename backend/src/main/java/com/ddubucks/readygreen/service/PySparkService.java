package com.ddubucks.readygreen.service;

import org.springframework.stereotype.Service;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

@Service
public class PySparkService {

    public List<String> calculateDistances(double latitude, double longitude) {
        List<String> sortedLocations = new ArrayList<>();

        try {
            String[] command = new String[] {
                    "spark-submit", "/home/ubuntu/pyspark_script.py", String.valueOf(latitude), String.valueOf(longitude)
            };
            Process process = Runtime.getRuntime().exec(command);

            // PySpark 스크립트에서 결과를 받음
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                sortedLocations.add(line);
            }
            process.waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sortedLocations;
    }
}

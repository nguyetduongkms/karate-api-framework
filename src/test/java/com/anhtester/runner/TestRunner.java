package com.anhtester.runner;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import io.github.cdimascio.dotenv.Dotenv;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import net.masterthought.cucumber.Reportable;
import net.masterthought.cucumber.presentation.PresentationMode;
import net.masterthought.cucumber.sorting.SortingMethod;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class TestRunner {

    @Test
    void runAllTests() {

        // ----------------------------------------------------------------
        // [STEP 1] LOAD .env FILE INTO SYSTEM PROPERTIES
        // dotenv-java reads .env from the project root.
        // ignoreIfMissing() silently skips when .env is absent (CI uses real env vars).
        // Each entry is set as a System property so karate-config.js can read it
        // via java.lang.System.getProperty() / java.lang.System.getenv().
        // ----------------------------------------------------------------
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
        dotenv.entries().forEach(e -> System.setProperty(e.getKey(), e.getValue()));

        // ----------------------------------------------------------------
        // [STEP 2] START KARATE PARALLEL RUNNER
        // ----------------------------------------------------------------
        Results results = Runner
                .path("classpath:features")
                .outputCucumberJson(true)   // ← QUAN TRỌNG
                .parallel(5);

        // ----------------------------------------------------------------
        // [STEP 3] GENERATE CUCUMBER HTML REPORT (Masterthought)
        // ----------------------------------------------------------------
        generateReport(results.getReportDir());

        // ----------------------------------------------------------------
        // [STEP 4] ASSERT — fail the build if any scenario failed
        // ----------------------------------------------------------------
        assertEquals(
            0,
            results.getFailCount(),
            results.getFailCount()
                + " test case(s) FAILED!\n"
                + "See details at: target/cucumber-html-reports/overview-features.html"
        );
    }

    /**
     * Generates a Masterthought Cucumber HTML report from Karate's JSON output.
     * Output: target/cucumber-html-reports/overview-features.html
     */
    private void generateReport(String karateOutputPath) {

        Collection<File> jsonFiles = org.apache.commons.io.FileUtils.listFiles(
            new File(karateOutputPath),
            new String[]{"json"},
            true
        );

        List<String> jsonPaths = new ArrayList<>();
        for (File file : jsonFiles) {
            jsonPaths.add(file.getAbsolutePath());
        }

        if (jsonPaths.isEmpty()) {
            System.err.println("[WARN] No JSON report files found at: " + karateOutputPath);
            return;
        }

        File reportOutputDir = new File("target/cucumber-html-reports");

        Configuration config = new Configuration(reportOutputDir, "Karate API Framework");
        config.setBuildNumber("1");
        config.setSortingMethod(SortingMethod.ALPHABETICAL);
        config.addPresentationModes(PresentationMode.EXPAND_ALL_STEPS);
        config.addPresentationModes(PresentationMode.PARALLEL_TESTING);

        config.addClassifications("Environment", System.getProperty("karate.env", "dev"));
        config.addClassifications("Executed By",  System.getProperty("user.name", "CI/CD"));
        config.addClassifications("Target URL",   "https://api.anhtester.com");
        config.addClassifications("Framework",    "Karate " + System.getProperty("karate.version", "1.4.1"));
        config.addClassifications("Execution",    "Parallel (4 threads)");

        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        Reportable result = reportBuilder.generateReports();

        System.out.println("=".repeat(60));
        System.out.println("📊 CUCUMBER HTML REPORT GENERATED SUCCESSFULLY!");
        System.out.println("📁 Output path: " + reportOutputDir.getAbsolutePath());
        System.out.println("🌐 Open file: target/cucumber-html-reports/overview-features.html");
        System.out.println("=".repeat(60));
    }
}

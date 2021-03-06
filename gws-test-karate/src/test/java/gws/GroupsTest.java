package gws;

import com.intuit.karate.cucumber.CucumberRunner;
import com.intuit.karate.cucumber.KarateStats;
import cucumber.api.CucumberOptions;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

//This exists so when you run "mvn clean package" the tests run automatically.

@CucumberOptions(tags = {"~@ignore"})

public class GroupsTest {

    @Test
    public void testParallel() {
        KarateStats stats = CucumberRunner.parallel(getClass(), 1, "target/surefire-reports");
        assertTrue("scenarios failed", stats.getFailCount() == 0);
    }

}

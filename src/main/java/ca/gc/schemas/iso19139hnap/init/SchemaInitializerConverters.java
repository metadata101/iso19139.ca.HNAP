package ca.gc.schemas.iso19139hnap.init;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.utils.Log;
import org.springframework.context.ApplicationListener;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Pattern;

/**
 * This class is for setting up a schema conversion files
 * <p>
 * It watches the system startup and gives us the opportunity to do any setup required at the appropriate time.
 * <p>
 * See config-spring-geonetwork.xml in this schema
 */
public class SchemaInitializerConverters implements
    ApplicationListener<GeonetworkDataDirectory.GeonetworkDataDirectoryInitializedEvent> {

    private static final String conversionDir = "xsl/conversion/"; // "local" or "external"
    private static String jarXSLPattern = conversionDir + "**/*.xsl"; //find xsl files in the JAR

    // for each of the RDF files included in this JAR, if its not in the corresponding location in datadir, then we copy it in
    public void ConfigureThesauruses(Path conversionPath) throws IOException {
        PathMatchingResourcePatternResolver resolver =
            new PathMatchingResourcePatternResolver(Thread.currentThread().getContextClassLoader());
        //for each of the .rdf files
        for (Resource r : resolver.getResources(jarXSLPattern)) {
            String fname = r.getFilename(); //i.e. conversion/import/iso19139-to-iso19139.ca.HNAP.xsl
            String[] subDirs = r.getURI().toURL().getPath().split(Pattern.quote("/"));
            String dir = subDirs[subDirs.length - 2]; // ie. "import"
            ///put in - xsl/conversion/import/iso19139-to-iso19139.ca.HNAP.xsl
            //ensure that dirs exist
            Files.createDirectories(Paths.get(conversionPath.toString(), dir));
            //full path to put the .xsl
            Path correspondingDataDirFile = Paths.get(conversionPath.toString(), dir, fname);
            if (!Files.exists(correspondingDataDirFile)) {
                //need to copy it in...
                Log.info(Geonet.SCHEMA_MANAGER, "ISO19139.HNAP: SchemaInitializerConverters: copying conversion files: " + fname + " to " + correspondingDataDirFile.toString());
                try (InputStream is = r.getInputStream()) { //auto close
                    Files.copy(is, correspondingDataDirFile);
                }
            }
        }
    }


    //when the data dir is configured, we're good to copy in our conversion files
    @Override
    public void onApplicationEvent(GeonetworkDataDirectory.GeonetworkDataDirectoryInitializedEvent event) {
        Path conversionPath = event.getSource().getWebappDir().resolve(conversionDir);
        try {
            ConfigureThesauruses(conversionPath);
        } catch (IOException e) {
            Log.error(Geonet.SCHEMA_MANAGER, "SchemaInitializerConverters: preloading conversion files", e);
        }
    }
}

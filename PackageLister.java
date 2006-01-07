import java.io.File;
import java.io.IOException;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.zip.*;

public class PackageLister
{
    private static void populateSet(File jar, Set packages) throws IOException
    {
        ZipFile zipFile = new ZipFile(jar);
        
        for(Enumeration e = zipFile.entries(); e.hasMoreElements();)
        {
            ZipEntry entry = (ZipEntry) e.nextElement();
            String path = entry.getName();
            
            if(path.endsWith(".class"))
            {
                String parentPath = new File(path).getParent();
                packages.add(parentPath);
            }
        }
    }
    
    public static void main(String[] args)
    {
        try
        {
            HashSet packages = new HashSet();
            
            for(int i = 0; i < args.length; i++)
            {
                String arg=args[i];
                File jar = new File(arg);
                populateSet(jar, packages);
            }
            
            for(Iterator i = packages.iterator(); i.hasNext();)
            {
                String pkg = (String) i.next();
                System.out.print("+" + pkg.replaceAll("/",".") + " ");
            }

            System.out.println();
			
        }
        catch(IOException e)
        {
            System.err.println(e);
            System.exit(1);
        }
    }
}

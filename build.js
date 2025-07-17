const fs = require('fs-extra');
const path = require('path');

// Build configuration
const BUILD_CONFIG = {
    sourceDir: './src',
    distDir: './dist',
    templateFile: './src/config.template.js',
    configFile: './src/config.js'
};

async function build() {
    console.log('🚀 Building Wilde Liga Bremen...');
    
    try {
        // 1. Clean and create dist directory
        await fs.remove(BUILD_CONFIG.distDir);
        await fs.ensureDir(BUILD_CONFIG.distDir);
        console.log('✅ Cleaned dist directory');
        
        // 2. Copy all files from src to dist
        await fs.copy(BUILD_CONFIG.sourceDir, BUILD_CONFIG.distDir, {
            filter: (src) => {
                // Exclude template file and original config.js
                const fileName = path.basename(src);
                return fileName !== 'config.template.js' && fileName !== 'config.js';
            }
        });
        console.log('✅ Copied source files');
        
        // 3. Process config template with environment variables
        const templateContent = await fs.readFile(BUILD_CONFIG.templateFile, 'utf8');
        
        const supabaseUrl = process.env.SUPABASE_URL;
        const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
        
        if (!supabaseUrl || !supabaseAnonKey) {
            throw new Error('Missing required environment variables: SUPABASE_URL and SUPABASE_ANON_KEY');
        }
        
        const processedContent = templateContent
            .replace('{{SUPABASE_URL}}', supabaseUrl)
            .replace('{{SUPABASE_ANON_KEY}}', supabaseAnonKey);
        
        // 4. Write processed config to dist
        await fs.writeFile(path.join(BUILD_CONFIG.distDir, 'config.js'), processedContent);
        console.log('✅ Generated config.js with environment variables');
        
        // 5. Update HTML files to use relative paths if needed
        await updateHtmlFiles();
        
        console.log('🎉 Build completed successfully!');
        console.log('📁 Files ready in ./dist directory');
        
    } catch (error) {
        console.error('❌ Build failed:', error.message);
        process.exit(1);
    }
}

async function updateHtmlFiles() {
    const htmlFiles = ['wilde-liga.html', 'admin.html'];
    
    for (const htmlFile of htmlFiles) {
        const filePath = path.join(BUILD_CONFIG.distDir, htmlFile);
        
        if (await fs.pathExists(filePath)) {
            let content = await fs.readFile(filePath, 'utf8');
            
            // Update any absolute paths to relative paths if needed
            // This is where you could add any HTML processing logic
            
            await fs.writeFile(filePath, content);
        }
    }
    
    console.log('✅ Updated HTML files');
}

// Run build
build();

// import { createClient } from '@supabase/supabase-js';
// import { v4 as uuidv4 } from 'uuid';
// import QRCode from 'qrcode';

// // 🚨 1. UPDATE your credentials
// const SUPABASE_URL = 'https://klwaqemvildisaisafpb.supabase.co';
// const SUPABASE_ANON_KEY = 'sb_publishable_h08bBUGjoap1SQDzgAQ4TA_g4bi24L7'; 
// const TABLE_NAME = 'qr_codes';

// // Initialize the Supabase client
// const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// /**
//  * Generates a unique QR code and stores its data, linked to the currently authenticated user.
//  */
// async function generateAndStoreQRCode() {
//     try {
//         // 🔑 STEP 1: Get the user ID of the currently authenticated user.
//         // FIX: Corrected function name to getUser() and destructuring key to 'user'
//         const { data: { user }, error: authError } = await supabase.auth.getUser();

//         if (authError || !user) {
//             console.error('❌ Authentication Error: No user logged in or an Auth error occurred.', authError?.message || 'Unauthorized');
//             return;
//         }

//         // FIX: Access ID via 'user.id'
//         const userId = user.id; 
//         console.log(`👤 Authenticated user ID: ${userId}`);

//         // 📝 STEP 2: Generate Unique Data and the QR Code.
//         const uniqueId = uuidv4();
//         console.log(`Generated Unique ID: ${uniqueId}`);

//         const qrCodeBase64 = await QRCode.toDataURL(uniqueId);
//         console.log('🖼️ QR Code generated successfully.');

//         // 💾 STEP 3: Store Data into Supabase.
//         const { data, error } = await supabase
//             .from(TABLE_NAME)
//             .insert([
//                 {
//                     unique_identifier: uniqueId,
//                     qr_code_base64: qrCodeBase64,
//                     // FIX: Removed incorrect 'id: userId' and added correct 'user_id: userId'
//                     user_id: userId, 
//                 },
//             ])
//             .select(); 

//         if (error) {
//             console.error('❌ Supabase Insertion Error:', error.message);
//             return;
//         }

//         console.log('✅ QR Code data stored in Supabase successfully!');
//         console.log('Stored Data:', data);

//     } catch (err) {
//         console.error('🚨 A major error occurred during execution:', err.message);
//     }
// }

// generateAndStoreQRCode();


import { createClient } from '@supabase/supabase-js';
import { v4 as uuidv4 } from 'uuid';
import QRCode from 'qrcode';

// ----------------------------------------------------------------------
// 🚨 1. REQUIRED SUBSTITUTION: Replace with your Service Role Key
// WARNING: This key grants full access to your database. Use on a secure local machine only.
// Get this key from Project Settings -> API -> Service Role Key (secret)
const SUPABASE_SERVICE_ROLE_KEY = 'sb_publishable_h08bBUGjoap1SQDzgAQ4TA_g4bi24L7'; 
// ----------------------------------------------------------------------

const SUPABASE_URL = 'https://klwaqemvildisaisafpb.supabase.co';
const TABLE_NAME = 'qr_codes';

// Initialize the Supabase client using the Service Role Key
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

/**
 * Generates a unique QR code and stores its data, linked to the specified user.
 * This function bypasses Row Level Security (RLS) because it uses the Service Role Key.
 * * @param {string} targetUserId - The UUID of the user to link the QR code to.
 */
async function generateAndStoreQRCode(targetUserId) {
    try {
        // STEP 1: Use the provided User ID directly
        const userId = targetUserId; 
        
        if (!userId) {
            console.error('❌ Error: Target user ID must be provided.');
            return;
        }

        console.log(`👤 Target User ID (via Service Role): ${userId}`);

        // STEP 2: Generate Unique Data and the QR Code.
        const uniqueId = uuidv4();
        console.log(`Generated Unique ID: ${uniqueId}`);

        // Generate the QR Code Image as a Base64 Data URL
        const qrCodeBase64 = await QRCode.toDataURL(uniqueId);
        console.log('🖼️ QR Code generated successfully.');

        // STEP 3: Store Data into Supabase.
        const { data, error } = await supabase
            .from(TABLE_NAME)
            .insert([
                {
                    unique_identifier: uniqueId,
                    qr_code_base64: qrCodeBase64,
                    // Link the record using the correct column name
                    user_id: userId, 
                },
            ])
            .select(); 

        if (error) {
            console.error('❌ Supabase Insertion Error:', error.message);
            return;
        }

        console.log('✅ QR Code data stored in Supabase successfully!');
        console.log('Stored Data:', data);

    } catch (err) {
        console.error('🚨 A major error occurred during execution:', err.message);
    }
}

// ---------------------------------------------------------------------------------------------------
// 🚨 2. REQUIRED SUBSTITUTION: Replace with the actual User ID from your Flutter app's screenshot.
// This is the user who needs the QR code (e.g., rodrigomarco001@gmail.com)
generateAndStoreQRCode('66151d36-77c5-4d15-8213-2a763538148b'); 
// ---------------------------------------------------------------------------------------------------

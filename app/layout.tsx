import './globals.css'
import type { Metadata } from 'next'
export const metadata:Metadata={title:'Wishloom — make a little world for someone you love',description:'Private, personal gift experiences made from your memories.'}
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}</body></html>}
